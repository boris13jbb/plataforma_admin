import * as admin from "firebase-admin";
import {getProduct} from "./products";

/** App default del hub (Auth + Firestore del proyecto plataforma-admin-jb). */
if (!admin.apps.length) {
  admin.initializeApp();
}

const productApps = new Map<string, admin.app.App>();

function parseServiceAccountJson(raw: string): admin.ServiceAccount {
  const parsed = JSON.parse(raw) as Record<string, unknown>;
  if (!parsed.project_id || !parsed.client_email || !parsed.private_key) {
    throw new Error("Service account JSON inválido (faltan campos).");
  }
  return {
    projectId: String(parsed.project_id),
    clientEmail: String(parsed.client_email),
    privateKey: String(parsed.private_key).replace(/\\n/g, "\n"),
  };
}

/**
 * Inicializa (o reutiliza) una app Admin SDK nombrada por productId.
 * El JSON del SA llega como secret de Cloud Functions.
 */
export function getProductApp(
  productId: string,
  serviceAccountJson: string,
): admin.app.App {
  const existing = productApps.get(productId);
  if (existing) return existing;

  const product = getProduct(productId);
  if (!serviceAccountJson?.trim()) {
    throw new Error(
      `Falta el secret de service account para ${productId} (${product.serviceAccountSecret}).`,
    );
  }

  const credential = admin.credential.cert(
    parseServiceAccountJson(serviceAccountJson),
  );
  const app = admin.initializeApp(
    {
      credential,
      projectId: product.firebaseProjectId,
    },
    productId,
  );
  productApps.set(productId, app);
  return app;
}

export function hubAuth(): admin.auth.Auth {
  return admin.auth();
}

export function hubDb(): admin.firestore.Firestore {
  return admin.firestore();
}

export function nowIso(): string {
  return new Date().toISOString();
}
