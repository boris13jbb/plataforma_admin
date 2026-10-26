import {HttpsError} from "firebase-functions/v2/https";
import type {HubProductOps} from "./types";
import * as coti from "./cotiapp";
import * as cv from "./cvmaker";

const registry: Record<string, HubProductOps> = {
  cotiapp: {
    metrics: coti.cotiMetrics,
    lookupUser: coti.cotiLookupUser,
    grant: coti.cotiGrant,
    revoke: coti.cotiRevoke,
    listGrants: coti.cotiListGrants,
  },
  cvmaker: {
    metrics: cv.cvMetrics,
    lookupUser: cv.cvLookupUser,
    grant: cv.cvGrant,
    revoke: async (app, actor, input) =>
      cv.cvRevoke(app, actor, {
        email: input.email,
        uid: input.uid,
        reason: input.reason,
      }),
    listGrants: cv.cvListGrants,
  },
};

/** Resuelve el connector de un productId (añadir apps futuras aquí). */
export function getProductOps(productId: string): HubProductOps {
  const ops = registry[productId];
  if (!ops) {
    throw new HttpsError(
      "invalid-argument",
      `Sin connector para producto: ${productId}`,
    );
  }
  return ops;
}
