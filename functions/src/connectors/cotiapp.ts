import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {HubAdminIdentity} from "../hubAuth";
import {nowIso} from "../productApps";

type PlanId = "pro" | "business";

function dbOf(app: admin.app.App) {
  return app.firestore();
}

function authOf(app: admin.app.App) {
  return app.auth();
}

async function resolveUser(
  app: admin.app.App,
  input: {email?: string; uid?: string},
): Promise<admin.auth.UserRecord> {
  const email = input.email?.trim().toLowerCase();
  const uid = input.uid?.trim();
  try {
    if (uid) return await authOf(app).getUser(uid);
    if (email) return await authOf(app).getUserByEmail(email);
  } catch {
    throw new HttpsError("not-found", "Usuario no encontrado en CotiApp.");
  }
  throw new HttpsError("invalid-argument", "email o uid requerido.");
}

async function writeAudit(
  app: admin.app.App,
  entry: Record<string, unknown>,
): Promise<void> {
  await dbOf(app).collection("adminAuditLogs").add({
    ...entry,
    createdAt: nowIso(),
  });
}

export async function cotiMetrics(app: admin.app.App) {
  const db = dbOf(app);
  const [usersCount, orgsCount, grantsActive, errorReports] = await Promise.all([
    db.collection("users").count().get(),
    db.collection("organizations").count().get(),
    db.collection("platformGrants").where("revokedAt", "==", null).count().get(),
    db.collection("errorReports").orderBy("createdAt", "desc").limit(20).get(),
  ]);
  const entitlementsSnap = await db
    .collection("entitlements")
    .where("source", "==", "admin_grant")
    .limit(200)
    .get();

  return {
    productId: "cotiapp",
    users: usersCount.data().count,
    organizations: orgsCount.data().count,
    activeGrants: grantsActive.data().count,
    adminGrantEntitlements: entitlementsSnap.size,
    recentErrors: errorReports.docs.map((d) => ({id: d.id, ...d.data()})),
  };
}

export async function cotiLookupUser(
  app: admin.app.App,
  input: {email?: string; uid?: string},
) {
  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const [profileSnap, entSnap] = await Promise.all([
    db.collection("users").doc(user.uid).get(),
    db.collection("entitlements").doc(user.uid).get(),
  ]);
  return {
    uid: user.uid,
    email: user.email ?? null,
    displayName:
      user.displayName ??
      (profileSnap.data()?.displayName as string | undefined) ??
      null,
    disabled: user.disabled,
    profile: profileSnap.exists ? profileSnap.data() : null,
    entitlements: entSnap.exists ? entSnap.data() : null,
  };
}

export async function cotiGrant(
  app: admin.app.App,
  actor: HubAdminIdentity,
  input: {
    email?: string;
    uid?: string;
    plan: string;
    reason: string;
    expiresAt?: string | null;
  },
) {
  const plan = input.plan.trim() as PlanId;
  if (plan !== "pro" && plan !== "business") {
    throw new HttpsError("invalid-argument", "plan debe ser pro o business.");
  }
  const reason = input.reason.trim();
  if (!reason) {
    throw new HttpsError("invalid-argument", "reason (motivo) requerido.");
  }

  let expiresAt: string | null = null;
  if (input.expiresAt) {
    const d = new Date(input.expiresAt);
    if (Number.isNaN(d.getTime())) {
      throw new HttpsError("invalid-argument", "expiresAt inválido.");
    }
    expiresAt = d.toISOString();
  }

  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const now = nowIso();
  const grantRef = db.collection("platformGrants").doc();
  const entRef = db.collection("entitlements").doc(user.uid);
  const existing = await entRef.get();
  const createdAt = (existing.data()?.createdAt as string) || now;

  const entitlements = {
    uid: user.uid,
    plan,
    subscriptionStatus: "active",
    source: "admin_grant",
    grantExpiresAt: expiresAt,
    grantReason: reason,
    grantedByUid: actor.uid,
    grantId: grantRef.id,
    createdAt,
    updatedAt: now,
  };

  const grant = {
    id: grantRef.id,
    targetUid: user.uid,
    plan,
    reason,
    grantedByUid: actor.uid,
    expiresAt,
    revokedAt: null,
    createdAt: now,
    updatedAt: now,
    sourceHub: "plataforma_admin",
  };

  const batch = db.batch();
  batch.set(entRef, entitlements, {merge: true});
  batch.set(grantRef, grant);
  await batch.commit();

  await writeAudit(app, {
    action: "hub_grant_entitlement",
    actorUid: actor.uid,
    actorEmail: actor.email,
    targetUid: user.uid,
    plan,
    reason,
    grantId: grantRef.id,
    expiresAt,
  });

  return {ok: true, grantId: grantRef.id, entitlements};
}

export async function cotiRevoke(
  app: admin.app.App,
  actor: HubAdminIdentity,
  input: {email?: string; uid?: string; grantId?: string},
) {
  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const now = nowIso();
  const entRef = db.collection("entitlements").doc(user.uid);
  const entSnap = await entRef.get();
  const prev = entSnap.data() ?? {};
  const grantId = (input.grantId || prev.grantId || "").toString();

  await entRef.set(
    {
      uid: user.uid,
      plan: "free",
      subscriptionStatus: "active",
      source: "admin_revoke",
      grantExpiresAt: null,
      grantReason: null,
      grantedByUid: null,
      grantId: null,
      updatedAt: now,
      createdAt: (prev.createdAt as string) || now,
      stripeCustomerId: prev.stripeCustomerId ?? null,
      stripeSubscriptionId: prev.stripeSubscriptionId ?? null,
    },
    {merge: true},
  );

  if (grantId) {
    await db.collection("platformGrants").doc(grantId).set(
      {
        revokedAt: now,
        updatedAt: now,
        revokedByUid: actor.uid,
        sourceHub: "plataforma_admin",
      },
      {merge: true},
    );
  }

  await writeAudit(app, {
    action: "hub_revoke_grant",
    actorUid: actor.uid,
    actorEmail: actor.email,
    targetUid: user.uid,
    grantId: grantId || null,
  });

  return {ok: true};
}

export async function cotiListGrants(app: admin.app.App, limit = 50) {
  const snap = await dbOf(app)
    .collection("platformGrants")
    .orderBy("createdAt", "desc")
    .limit(Math.min(limit, 100))
    .get();
  return {grants: snap.docs.map((d) => d.data())};
}
