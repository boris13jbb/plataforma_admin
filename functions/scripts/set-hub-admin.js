/**
 * One-shot: set hubAdmin claim + hubAdmins doc for the first operator.
 * Uses Application Default Credentials (gcloud auth application-default login).
 */
const admin = require("firebase-admin");

const PROJECT_ID = "plataforma-admin-jb";
const UID = process.env.HUB_ADMIN_UID || "nuBMRwV1cxTOlnSKMxJSczhYrlH3";
const EMAIL = process.env.HUB_ADMIN_EMAIL || "boris13jb@gmail.com";

async function main() {
  admin.initializeApp({projectId: PROJECT_ID});
  const auth = admin.auth();
  const db = admin.firestore();

  const user = await auth.getUser(UID);
  console.log("user.email=", user.email);
  console.log("claims.before=", JSON.stringify(user.customClaims || {}));

  await auth.setCustomUserClaims(UID, {
    ...(user.customClaims || {}),
    hubAdmin: true,
  });

  const now = new Date().toISOString();
  await db.collection("hubAdmins").doc(UID).set(
    {
      uid: UID,
      email: user.email || EMAIL,
      createdAt: now,
      updatedAt: now,
      createdBy: "manual_set_hub_admin_script",
    },
    {merge: true},
  );

  await db.collection("hubAuditLogs").add({
    action: "manual_set_hub_admin",
    actorUid: "script",
    targetUid: UID,
    createdAt: now,
  });

  const after = await auth.getUser(UID);
  console.log("claims.after=", JSON.stringify(after.customClaims || {}));
  console.log("OK: hubAdmin set. Sign out and sign in again in the app.");
}

main().catch((err) => {
  console.error("FAILED:", err && err.message ? err.message : err);
  process.exit(1);
});
