/**
 * Sonda negativa HTTP contra callables desplegadas (sin token).
 * No imprime secretos. No modifica datos.
 *
 *   node scripts/negative-callable-probe.js
 */
const REGION = "us-central1";
const PROJECT = "plataforma-admin-jb";

async function probe(name, data = {}) {
  const url = `https://${REGION}-${PROJECT}.cloudfunctions.net/${name}`;
  const res = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({data}),
  });
  let body;
  try {
    body = await res.json();
  } catch {
    body = {raw: "(non-json)"};
  }
  const errCode = body?.error?.status || body?.error?.message || null;
  return {name, http: res.status, errCode, ok: res.ok};
}

async function main() {
  const results = [];
  results.push(await probe("hubListProducts", {}));
  results.push(await probe("hubGrant", {productId: "cotiapp", plan: "pro"}));
  results.push(await probe("hubRevoke", {productId: "cotiapp"}));
  results.push(await probe("hubProductMetrics", {productId: ""}));

  for (const r of results) {
    console.log(
      `${r.name}: http=${r.http} ok=${r.ok} err=${r.errCode || "(none)"}`,
    );
  }

  const allDenied = results.every((r) => !r.ok && r.http >= 400);
  if (!allDenied) {
    console.error("FAIL: alguna callable aceptó invocación sin Authorization");
    process.exitCode = 2;
  } else {
    console.log("OK: callables rechazan invocación sin autorización");
  }
}

main().catch((e) => {
  console.error("FAILED:", e.message || e);
  process.exit(1);
});
