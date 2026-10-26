import {HttpsError} from "firebase-functions/v2/https";

/**
 * Validaciones puras del bootstrap del primer hubAdmin (sin I/O ni secrets I/O).
 * La callable sigue siendo la única vía de mutación.
 */
export function assertBootstrapRequest(params: {
  uid: string | undefined;
  providedSecret: string;
  expectedSecret: string;
  adminExists: boolean;
}): {uid: string} {
  const uid = params.uid?.trim();
  if (!uid) {
    throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
  }
  if (!params.expectedSecret || params.providedSecret !== params.expectedSecret) {
    throw new HttpsError("permission-denied", "Secreto de bootstrap inválido.");
  }
  if (params.adminExists) {
    throw new HttpsError(
      "failed-precondition",
      "Ya existe al menos un hubAdmin.",
    );
  }
  return {uid};
}
