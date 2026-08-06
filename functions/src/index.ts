import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {assertHubAdmin, writeHubAudit, hubAuth, hubDb, nowIso} from "./hubAuth";
import {getProductApp} from "./productApps";
import {getProduct, listProductsPublic} from "./products";
import * as coti from "./connectors/cotiapp";
import * as cv from "./connectors/cvmaker";

const bootstrapSecret = defineSecret("HUB_ADMIN_BOOTSTRAP_SECRET");
const saCotiapp = defineSecret("SA_COTIAPP_JSON");
const saCvmaker = defineSecret("SA_CVMAKER_JSON");

const productSecrets = [saCotiapp, saCvmaker];

function saJsonFor(productId: string): string {
  if (productId === "cotiapp") return saCotiapp.value();
  if (productId === "cvmaker") return saCvmaker.value();
  throw new HttpsError(
    "invalid-argument",
    `No hay service account configurada para ${productId}.`,
  );
}

function productApp(productId: string): admin.app.App {
  getProduct(productId);
  return getProductApp(productId, saJsonFor(productId));
}

/**
 * Primer hubAdmin: solo si aún no hay ninguno y el secreto coincide.
 */
export const bootstrapHubAdmin = onCall(
  {secrets: [bootstrapSecret]},
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }
    const secret = String(request.data?.secret ?? "");
    const expected = bootstrapSecret.value();
    if (!expected || secret !== expected) {
      throw new HttpsError("permission-denied", "Secreto de bootstrap inválido.");
    }

    const existing = await hubDb().collection("hubAdmins").limit(1).get();
    if (!existing.empty) {
      throw new HttpsError(
        "failed-precondition",
        "Ya existe al menos un hubAdmin.",
      );
    }

    const uid = request.auth.uid;
    const email = (request.auth.token.email as string | undefined) ?? null;
    await hubAuth().setCustomUserClaims(uid, {hubAdmin: true});
    await hubDb().collection("hubAdmins").doc(uid).set({
      uid,
      email,
      createdAt: nowIso(),
      updatedAt: nowIso(),
      createdBy: "bootstrap",
    });
    await writeHubAudit({
      action: "bootstrap_hub_admin",
      actorUid: uid,
      targetUid: uid,
    });
    return {
      ok: true,
      uid,
      message: "Cierra sesión y vuelve a entrar para refrescar el token.",
    };
  },
);

export const hubListProducts = onCall(async (request) => {
  assertHubAdmin(request.auth);
  return {products: listProductsPublic()};
});

export const hubProductMetrics = onCall(
  {secrets: productSecrets},
  async (request) => {
    const actor = assertHubAdmin(request.auth);
    const productId = String(request.data?.productId ?? "").trim();
    if (!productId) {
      throw new HttpsError("invalid-argument", "productId requerido.");
    }
    const app = productApp(productId);
    const metrics =
      productId === "cotiapp"
        ? await coti.cotiMetrics(app)
        : await cv.cvMetrics(app);
    await writeHubAudit({
      action: "metrics",
      actorUid: actor.uid,
      productId,
    });
    return metrics;
  },
);

export const hubLookupUser = onCall(
  {secrets: productSecrets},
  async (request) => {
    assertHubAdmin(request.auth);
    const productId = String(request.data?.productId ?? "").trim();
    const email = String(request.data?.email ?? "").trim();
    const uid = String(request.data?.uid ?? "").trim();
    if (!productId) {
      throw new HttpsError("invalid-argument", "productId requerido.");
    }
    const app = productApp(productId);
    const user =
      productId === "cotiapp"
        ? await coti.cotiLookupUser(app, {email, uid})
        : await cv.cvLookupUser(app, {email, uid});
    return {user};
  },
);

export const hubGrant = onCall(
  {secrets: productSecrets},
  async (request) => {
    const actor = assertHubAdmin(request.auth);
    const productId = String(request.data?.productId ?? "").trim();
    const email = String(request.data?.email ?? "").trim();
    const uid = String(request.data?.uid ?? "").trim();
    const plan = String(request.data?.plan ?? "pro").trim();
    const reason = String(request.data?.reason ?? "").trim();
    const expiresAt = request.data?.expiresAt
      ? String(request.data.expiresAt)
      : null;

    if (!productId) {
      throw new HttpsError("invalid-argument", "productId requerido.");
    }
    const product = getProduct(productId);
    if (!product.grantPlans.includes(plan)) {
      throw new HttpsError(
        "invalid-argument",
        `Plan ${plan} no permitido para ${productId}. Usa: ${product.grantPlans.join(", ")}`,
      );
    }

    const app = productApp(productId);
    const result =
      productId === "cotiapp"
        ? await coti.cotiGrant(app, actor, {email, uid, plan, reason, expiresAt})
        : await cv.cvGrant(app, actor, {email, uid, plan, reason, expiresAt});

    await writeHubAudit({
      action: "grant",
      actorUid: actor.uid,
      productId,
      plan,
      reason,
      targetEmail: email || null,
      targetUid: uid || null,
    });
    return result;
  },
);

export const hubRevoke = onCall(
  {secrets: productSecrets},
  async (request) => {
    const actor = assertHubAdmin(request.auth);
    const productId = String(request.data?.productId ?? "").trim();
    const email = String(request.data?.email ?? "").trim();
    const uid = String(request.data?.uid ?? "").trim();
    const grantId = String(request.data?.grantId ?? "").trim();
    const reason = String(request.data?.reason ?? "").trim();

    if (!productId) {
      throw new HttpsError("invalid-argument", "productId requerido.");
    }
    const app = productApp(productId);
    const result =
      productId === "cotiapp"
        ? await coti.cotiRevoke(app, actor, {email, uid, grantId})
        : await cv.cvRevoke(app, actor, {email, uid, reason});

    await writeHubAudit({
      action: "revoke",
      actorUid: actor.uid,
      productId,
      targetEmail: email || null,
      targetUid: uid || null,
    });
    return result;
  },
);

export const hubListGrants = onCall(
  {secrets: productSecrets},
  async (request) => {
    assertHubAdmin(request.auth);
    const productId = String(request.data?.productId ?? "").trim();
    const limit = Number(request.data?.limit ?? 50);
    if (!productId) {
      throw new HttpsError("invalid-argument", "productId requerido.");
    }
    const app = productApp(productId);
    return productId === "cotiapp"
      ? coti.cotiListGrants(app, limit)
      : cv.cvListGrants(app, limit);
  },
);
