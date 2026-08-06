import {HttpsError} from "firebase-functions/v2/https";
import {hubAuth, hubDb, nowIso} from "./productApps";

export type HubAdminIdentity = {
  uid: string;
  email: string | null;
};

export function assertHubAdmin(
  auth: {uid: string; token: Record<string, unknown>} | undefined,
): HubAdminIdentity {
  if (!auth?.uid) {
    throw new HttpsError("unauthenticated", "Debes iniciar sesión en el hub.");
  }
  if (auth.token.hubAdmin !== true) {
    throw new HttpsError(
      "permission-denied",
      "Se requiere rol hubAdmin en el proyecto plataforma-admin-jb.",
    );
  }
  return {
    uid: auth.uid,
    email: (auth.token.email as string | undefined) ?? null,
  };
}

export async function writeHubAudit(
  entry: Record<string, unknown>,
): Promise<void> {
  await hubDb().collection("hubAuditLogs").add({
    ...entry,
    createdAt: nowIso(),
  });
}

export {hubAuth, hubDb, nowIso};
