# Checklist de producción — Plataforma Admin

Actualizado: 2026-10-25 (auditoría final previa a Internal Testing — solo lectura).

## Estado global

**LISTO CON PENDIENTES NO BLOQUEANTES** para carga manual a Internal Testing.  
Verificado en esta auditoría: `flutter analyze` OK; `flutter test` 12 OK; `functions` npm test 12 OK; AAB/APK firma release OK.  
Pendientes humanos (no bloquean la subida técnica del AAB): política/Data safety, ficha Play, testers, Play App Signing en Console, autorización de subida. App Check sigue opcional (sin SDK/enforcement).

## Seguridad

- [x] `assertHubAdmin` en servidor
- [x] Unit tests authz + gate bootstrap (`functions/test/`)
- [x] Sonda HTTP sin token → 401
- [x] `AsyncGuard` + tests Flutter
- [x] Firestore hub rules deniegan clientes
- [x] Secrets no versionados
- [x] `listProducts` no enmascara authz
- [x] **Opción B:** UI bootstrap oculta en `kReleaseMode` (callable backend **sigue activa**; ver [HUB_ADMIN_OPS.md](HUB_ADMIN_OPS.md))
- [ ] Limitar cuentas hubAdmin (humano) — ver [HUB_ADMIN_OPS.md](HUB_ADMIN_OPS.md)
- [ ] App Check — plan en [APP_CHECK.md](APP_CHECK.md) (**sin enforcement**)
- [ ] Política de privacidad + Play Data safety — inventario en [PRIVACY_DATA_INVENTORY.md](PRIVACY_DATA_INVENTORY.md)

## Android / Play

- [x] applicationId `com.plataformaadmin.plataforma_admin`
- [x] Firma release + SHA en Firebase
- [x] AAB/APK verificados
- [x] Pruebas manuales release (login hubAdmin, dashboard, métricas, lookup, sign-out, denegación)
- [ ] Play App Signing + Internal Testing track — **requiere autorización**
- [ ] URL política de privacidad en Play Console

## iOS

- [ ] macOS + IPA / TestFlight — bloqueado en Windows

## Regresión

| Comando | Esperado |
|---------|----------|
| `flutter analyze` | No issues |
| `flutter test` | All passed |
| `cd functions && npm test` | All passed |
| `apksigner` / `keytool` en artefactos | SHA release |

No deploy Functions. No publicación tiendas sin autorización.
