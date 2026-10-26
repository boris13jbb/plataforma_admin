import type * as admin from "firebase-admin";
import type {HubAdminIdentity} from "../hubAuth";

/** Contrato estable para connectors de producto (apps futuras). */
export type HubProductOps = {
  metrics(app: admin.app.App): Promise<Record<string, unknown>>;
  lookupUser(
    app: admin.app.App,
    input: {email?: string; uid?: string},
  ): Promise<Record<string, unknown>>;
  grant(
    app: admin.app.App,
    actor: HubAdminIdentity,
    input: {
      email?: string;
      uid?: string;
      plan: string;
      reason: string;
      expiresAt?: string | null;
    },
  ): Promise<Record<string, unknown>>;
  revoke(
    app: admin.app.App,
    actor: HubAdminIdentity,
    input: {
      email?: string;
      uid?: string;
      grantId?: string;
      reason?: string;
    },
  ): Promise<Record<string, unknown>>;
  listGrants(
    app: admin.app.App,
    limit?: number,
  ): Promise<{grants: unknown[]}>;
};
