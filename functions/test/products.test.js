const {describe, it} = require("node:test");
const assert = require("node:assert/strict");
const {getProduct, listProductsPublic} = require("../lib/products");

describe("products registry", () => {
  it("lista productos públicos sin exponer secret names en payload", () => {
    const list = listProductsPublic();
    assert.ok(list.some((p) => p.id === "cotiapp"));
    assert.ok(list.some((p) => p.id === "cvmaker"));
    for (const p of list) {
      assert.equal("serviceAccountSecret" in p, false);
    }
  });

  it("rechaza productId desconocido", () => {
    assert.throws(() => getProduct("no-existe"), /Producto desconocido/);
  });

  it("planes grant cotiapp no incluyen enterprise", () => {
    const p = getProduct("cotiapp");
    assert.ok(p.grantPlans.includes("pro"));
    assert.ok(p.grantPlans.includes("business"));
    assert.equal(p.grantPlans.includes("enterprise"), false);
  });
});
