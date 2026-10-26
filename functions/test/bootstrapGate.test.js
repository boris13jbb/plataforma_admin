/**
 * Pruebas del gate de bootstrap (sin Emulator ni secretos reales).
 */
const {describe, it} = require("node:test");
const assert = require("node:assert/strict");
const {HttpsError} = require("firebase-functions/v2/https");
const {assertBootstrapRequest} = require("../lib/bootstrapGate");

describe("assertBootstrapRequest", () => {
  const base = {
    uid: "u-first",
    providedSecret: "ok-secret",
    expectedSecret: "ok-secret",
    adminExists: false,
  };

  it("acepta primer admin con secreto correcto", () => {
    const out = assertBootstrapRequest(base);
    assert.equal(out.uid, "u-first");
  });

  it("rechaza sin autenticación", () => {
    assert.throws(
      () => assertBootstrapRequest({...base, uid: undefined}),
      (err) => err instanceof HttpsError && err.code === "unauthenticated",
    );
  });

  it("rechaza secreto inválido o vacío esperado", () => {
    assert.throws(
      () => assertBootstrapRequest({...base, providedSecret: "wrong"}),
      (err) => err instanceof HttpsError && err.code === "permission-denied",
    );
    assert.throws(
      () => assertBootstrapRequest({...base, expectedSecret: ""}),
      (err) => err instanceof HttpsError && err.code === "permission-denied",
    );
  });

  it("rechaza si ya existe hubAdmin", () => {
    assert.throws(
      () => assertBootstrapRequest({...base, adminExists: true}),
      (err) => err instanceof HttpsError && err.code === "failed-precondition",
    );
  });
});
