/**
 * Pruebas negativas de assertHubAdmin (sin Emulator ni red).
 * Requiere: npm run build
 */
const {describe, it} = require("node:test");
const assert = require("node:assert/strict");
const {HttpsError} = require("firebase-functions/v2/https");
const {assertHubAdmin} = require("../lib/hubAuth");

describe("assertHubAdmin", () => {
  it("rechaza ausencia de auth (no autenticado)", () => {
    assert.throws(
      () => assertHubAdmin(undefined),
      (err) => err instanceof HttpsError && err.code === "unauthenticated",
    );
  });

  it("rechaza auth sin uid", () => {
    assert.throws(
      () => assertHubAdmin({uid: "", token: {hubAdmin: true}}),
      (err) => err instanceof HttpsError && err.code === "unauthenticated",
    );
  });

  it("rechaza autenticado sin claim hubAdmin", () => {
    assert.throws(
      () =>
        assertHubAdmin({
          uid: "user-sin-rol",
          token: {email: "noperm@example.com"},
        }),
      (err) => err instanceof HttpsError && err.code === "permission-denied",
    );
  });

  it("rechaza hubAdmin distinto de true estricto", () => {
    assert.throws(
      () =>
        assertHubAdmin({
          uid: "u1",
          token: {hubAdmin: false},
        }),
      (err) => err instanceof HttpsError && err.code === "permission-denied",
    );
    assert.throws(
      () =>
        assertHubAdmin({
          uid: "u1",
          token: {hubAdmin: "true"},
        }),
      (err) => err instanceof HttpsError && err.code === "permission-denied",
    );
  });

  it("acepta hubAdmin true", () => {
    const id = assertHubAdmin({
      uid: "admin-uid",
      token: {hubAdmin: true, email: "admin@example.com"},
    });
    assert.equal(id.uid, "admin-uid");
    assert.equal(id.email, "admin@example.com");
  });
});
