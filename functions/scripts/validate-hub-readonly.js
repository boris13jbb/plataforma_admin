/**
 * Validación de solo lectura del hub (sin grant/revoke).
 *
 * Comprueba:
 * - Usuario hubAdmin existe y tiene claim
 * - Documento hubAdmins
 *
 * Callables HTTPS con custom token requieren service account con signBlob
 * (ADC de usuario en local suele fallar). La prueba E2E de callables se
 * valida vía app + hubAuditLogs.
 *
 *   cd functions
 *   node scripts/validate-hub-readonly.js
 */
const admin = require("firebase-admin");

const PROJECT_ID = "plataforma-admin-jb";
const UID = process.env.HUB_ADMIN_UID || "nuBMRwV1cxTOlnSKMxJSczhYrlH3";

async function main() {
  admin.initializeApp({projectId: PROJECT_ID});
  const auth = admin.auth();
  const db = admin.firestore();

  const user = await auth.getUser(UID);
  const claims = user.customClaims || {};
  console.log("auth.email=", user.email || "(none)");
  console.log("auth.disabled=", user.disabled);
  console.log("auth.hubAdmin=", claims.hubAdmin === true);

  if (claims.hubAdmin !== true) {
    throw new Error("El usuario no tiene claim hubAdmin=true");
  }

  const doc = await db.collection("hubAdmins").doc(UID).get();
  console.log("hubAdmins.exists=", doc.exists);
  if (!doc.exists) {
    throw new Error("Falta documento hubAdmins/" + UID);
  }

  const audits = await db
      .collection("hubAuditLogs")
      .orderBy("createdAt", "desc")
      .limit(5)
      .get();
  console.log(
      "hubAuditLogs.recent=",
      audits.docs
          .map((d) => {
            const x = d.data();
            return `${x.createdAt}|${x.action}|${x.productId || "-"}`;
          })
          .join(" ; "),
  );

  console.log(
      "OK: claim hubAdmin + hubAdmins + auditoría legible (callables: ver app/Android)",
  );
}

main().catch((err) => {
  console.error("FAILED:", err && err.message ? err.message : err);
  process.exit(1);
});
