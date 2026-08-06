/** Registro de productos administrables desde el hub. */
export type ProductCapability =
  | "metrics"
  | "lookupUser"
  | "grant"
  | "revoke"
  | "listGrants";

export type ProductDefinition = {
  id: string;
  displayName: string;
  firebaseProjectId: string;
  /** Nombre del secret de Functions con el JSON de service account. */
  serviceAccountSecret: "SA_COTIAPP_JSON" | "SA_CVMAKER_JSON" | string;
  capabilities: ProductCapability[];
  grantPlans: string[];
  description: string;
};

export const PRODUCT_REGISTRY: ProductDefinition[] = [
  {
    id: "cotiapp",
    displayName: "CotiApp",
    firebaseProjectId: "cotiapp-saas-jb",
    serviceAccountSecret: "SA_COTIAPP_JSON",
    capabilities: ["metrics", "lookupUser", "grant", "revoke", "listGrants"],
    grantPlans: ["pro", "business"],
    description: "Cotizaciones SaaS — grants Pro/Business de cortesía",
  },
  {
    id: "cvmaker",
    displayName: "CV Maker",
    firebaseProjectId: "cvmaker-saas-jb",
    serviceAccountSecret: "SA_CVMAKER_JSON",
    capabilities: ["metrics", "lookupUser", "grant", "revoke", "listGrants"],
    grantPlans: ["pro"],
    description: "CVs SaaS — grants Pro de cortesía",
  },
];

export function getProduct(productId: string): ProductDefinition {
  const p = PRODUCT_REGISTRY.find((x) => x.id === productId);
  if (!p) {
    throw new Error(`Producto desconocido: ${productId}`);
  }
  return p;
}

export function listProductsPublic() {
  return PRODUCT_REGISTRY.map((p) => ({
    id: p.id,
    displayName: p.displayName,
    firebaseProjectId: p.firebaseProjectId,
    capabilities: p.capabilities,
    grantPlans: p.grantPlans,
    description: p.description,
  }));
}
