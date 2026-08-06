import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import type {HubAdminIdentity} from "../hubAuth";
import {nowIso} from "../productApps";

function dbOf(app: admin.app.App) {
  return app.firestore();
}

function authOf(app: admin.app.App) {
  return app.auth();
}

function isActiveAdminGrant(
  data: Record<string, unknown> | undefined,
  now = new Date(),
): boolean {
  if (!data) return false;
  if (data.source !== "admin_grant") return false;
  if (data.plan !== "pro") return false;
  if (data.subscriptionStatus !== "active") return false;
  const expires = data.grantExpiresAt as string | null | undefined;
  if (expires) {
    const t = new Date(expires).getTime();
    if (!Number.isNaN(t) && t <= now.getTime()) return false;
  }
  return true;
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
    throw new HttpsError("not-found", "Usuario no encontrado en CV Maker.");
  }
  throw new HttpsError("invalid-argument", "email o uid requerido.");
}

async function writeAudit(
  app: admin.app.App,
  entry: Record<string, unknown>,
): Promise<string> {
  const ref = dbOf(app).collection("adminAuditLogs").doc();
  const payload = {
    id: ref.id,
    ...entry,
    createdAt: nowIso(),
  };
  await ref.set(payload);
  return ref.id;
}

export async function cvMetrics(app: admin.app.App) {
  const db = dbOf(app);
  let authTotal = 0;
  let pageToken: string | undefined;
  do {
    const page = await authOf(app).listUsers(1000, pageToken);
    authTotal += page.users.length;
    pageToken = page.pageToken;
  } while (pageToken);

  const [entSnap, auditSnap] = await Promise.all([
    db.collection("entitlements").get(),
    db.collection("adminAuditLogs").orderBy("createdAt", "desc").limit(20).get(),
  ]);

  let proActive = 0;
  let freeEntitlements = 0;
  let adminGrantsActive = 0;
  for (const doc of entSnap.docs) {
    const data = doc.data() as Record<string, unknown>;
    if (data.plan === "free") freeEntitlements += 1;
    if (
      data.plan === "pro" &&
      (data.subscriptionStatus === "active" ||
        data.subscriptionStatus === "trialing")
    ) {
      proActive += 1;
    }
    if (isActiveAdminGrant(data)) adminGrantsActive += 1;
  }

  return {
    productId: "cvmaker",
    authUsers: authTotal,
    proActive,
    freeEntitlements,
    adminGrantsActive: adminGrantsActive,
    recentAudit: auditSnap.docs.map((d) => d.data()),
  };
}

export async function cvLookupUser(
  app: admin.app.App,
  input: {email?: string; uid?: string},
) {
  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const [profileSnap, entSnap, usageSnap] = await Promise.all([
    db.collection("users").doc(user.uid).get(),
    db.collection("entitlements").doc(user.uid).get(),
    db.collection("usage").doc(user.uid).get(),
  ]);
  const entitlement = entSnap.data() ?? null;
  const usage = usageSnap.data() ?? null;
  const profile = profileSnap.data() ?? null;

  return {
    uid: user.uid,
    email: user.email ?? null,
    displayName:
      (profile?.displayName as string | undefined) ||
      user.displayName ||
      null,
    disabled: user.disabled,
    emailVerified: user.emailVerified,
    profile,
    entitlements: entitlement,
    usage: {
      resumeCount: (usage?.resumeCount as number | undefined) ?? 0,
      updatedAt: (usage?.updatedAt as string | undefined) ?? null,
    },
    hasAdminGrant: isActiveAdminGrant(
      entitlement as Record<string, unknown> | undefined,
    ),
  };
}

export async function cvGrant(
  app: admin.app.App,
  actor: HubAdminIdentity,
  input: {
    email?: string;
    uid?: string;
    plan?: string;
    reason: string;
    expiresAt?: string | null;
  },
) {
  const plan = (input.plan || "pro").trim();
  if (plan !== "pro") {
    throw new HttpsError(
      "invalid-argument",
      "CV Maker solo admite plan pro de cortesía.",
    );
  }
  const reason = input.reason.trim();
  if (!reason) {
    throw new HttpsError("invalid-argument", "reason (motivo) requerido.");
  }

  let grantExpiresAt: string | null = null;
  if (input.expiresAt) {
    const parsed = new Date(input.expiresAt);
    if (Number.isNaN(parsed.getTime())) {
      throw new HttpsError("invalid-argument", "expiresAt inválido.");
    }
    if (parsed.getTime() <= Date.now()) {
      throw new HttpsError(
        "invalid-argument",
        "expiresAt debe ser una fecha futura.",
      );
    }
    grantExpiresAt = parsed.toISOString();
  }

  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const iso = nowIso();
  const ref = db.collection("entitlements").doc(user.uid);
  const existing = await ref.get();

  const entitlements = {
    uid: user.uid,
    plan: "pro" as const,
    subscriptionStatus: "active" as const,
    trialEndsAt: null,
    source: "admin_grant" as const,
    schemaVersion: 1,
    updatedAt: iso,
    grantedBy: actor.uid,
    grantedAt: iso,
    grantNote: reason,
    grantExpiresAt,
    createdAt: existing.exists
      ? (existing.data()?.createdAt ?? iso)
      : iso,
    sourceHub: "plataforma_admin",
  };

  await ref.set(entitlements, {merge: true});
  const auditId = await writeAudit(app, {
    action: "grant",
    targetUid: user.uid,
    targetEmail: user.email ?? null,
    adminUid: actor.uid,
    adminEmail: actor.email,
    note: reason,
    grantExpiresAt,
    sourceHub: "plataforma_admin",
  });

  return {ok: true, auditId, entitlements};
}

export async function cvRevoke(
  app: admin.app.App,
  actor: HubAdminIdentity,
  input: {email?: string; uid?: string; reason?: string},
) {
  const user = await resolveUser(app, input);
  const db = dbOf(app);
  const iso = nowIso();
  const ref = db.collection("entitlements").doc(user.uid);
  const existing = await ref.get();

  await ref.set(
    {
      uid: user.uid,
      plan: "free",
      subscriptionStatus: "active",
      trialEndsAt: null,
      source: "admin_revoke",
      schemaVersion: 1,
      updatedAt: iso,
      grantedBy: null,
      grantedAt: null,
      grantNote: null,
      grantExpiresAt: null,
      createdAt: existing.exists
        ? (existing.data()?.createdAt ?? iso)
        : iso,
      sourceHub: "plataforma_admin",
    },
    {merge: true},
  );

  const auditId = await writeAudit(app, {
    action: "revoke",
    targetUid: user.uid,
    targetEmail: user.email ?? null,
    adminUid: actor.uid,
    adminEmail: actor.email,
    note: input.reason?.trim() || null,
    grantExpiresAt: null,
    sourceHub: "plataforma_admin",
  });

  return {ok: true, auditId};
}

export async function cvListGrants(app: admin.app.App, limit = 50) {
  const snap = await dbOf(app)
    .collection("adminAuditLogs")
    .orderBy("createdAt", "desc")
    .limit(Math.min(limit, 100))
    .get();
  return {
    grants: snap.docs
      .map((d) => d.data())
      .filter((g) => g.action === "grant" || g.action === "revoke"),
  };
}
