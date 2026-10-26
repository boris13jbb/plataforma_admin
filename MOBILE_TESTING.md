# Pruebas móviles — Plataforma Admin

Documento vivo. Separación: completadas / fallidas / pendientes / autorización / externos.

## Entorno

| Elemento | Valor |
|----------|-------|
| Host | Windows 11 |
| Flutter | 3.44.2 / Dart 3.12.2 |
| Android físico | modelo `24115RA8EG` (dispositivo autorizado único en ADB) |
| Package | `com.plataformaadmin.plataforma_admin` |
| Backend | Functions `plataforma-admin-jb` · `us-central1` |
| Actualizado | 2026-10-25 (auditoría producción) |

---

## Completadas (con evidencia automatizada / ADB)

| ID | Caso | Evidencia |
|----|------|-----------|
| W1 | `flutter analyze` | Sin issues |
| W2 | `flutter test` | AsyncGuard + registry + api_errors |
| A1 | APK/AAB release firmados | `apksigner` / `jarsigner` + SHA release |
| A2 | Install release en físico | `adb install` Success; package presente; v1.0.0 |
| A2b | Firma instalada = release | `apksigner` sobre APK pulled del dispositivo |
| A3 | Arranque MainActivity | Activity resuelta y enfocada (sesión previa) |
| S1 | `assertHubAdmin` unit | `npm test` — 8 pass |
| S2 | Callable sin Authorization | `npm run probe:negative` → 401 |
| S4 | Candado anti-duplicado | Tests AsyncGuard + ProductAdminScreen |
| F1 | Firebase project + SHA remotas | MCP: projectId + sha1/sha256 release |

## Fallidas

| ID | Caso | Notas |
|----|------|-------|
| — | Ninguna en esta corrida automatizada | — |

## Checklist funcional (dispositivo) — estado

Marcar solo con evidencia. No declarar “aprobada” solo por descripción.

| # | Prueba | Estado |
|---|--------|--------|
| 1 | Inicio y navegación (launcher → UI) | **Aprobada con evidencia** (MainActivity / título) |
| 2 | Inicio de sesión (hubAdmin) | **Pendiente de interacción humana** |
| 3 | Persistencia de sesión (kill/reopen) | **Pendiente de interacción humana** |
| 4 | Cierre de sesión | **Pendiente de interacción humana** |
| 5 | Dashboard y listado de productos | **Pendiente de interacción humana** |
| 6 | Callables (metrics / lookup) sin grant/revoke reales | **Pendiente de interacción humana** |
| 7 | Errores de red (modo avión → mensaje amigable) | **Pendiente de interacción humana** |
| 8 | Sesión caducada / refresh token | **Pendiente de interacción humana** |
| 9 | Dobles pulsaciones (grant UI) | **Aprobada parcialmente** (unit AsyncGuard); UI manual pendiente |
| 10 | Acceso denegado sin hubAdmin | **Pendiente de interacción humana** (cuenta de prueba) |
| 11 | Logs sin secretos (logcat durante login) | **Pendiente de interacción humana** |
| 12 | Comportamiento tras reiniciar la app | **Pendiente de interacción humana** |

**No ejecutar** grants/revokes reales ni bootstrap con secreto en chat durante esta fase.

## Pendientes / externos

| ID | Caso | Motivo |
|----|------|--------|
| I2 | Compilar iOS | Mac + Xcode |
| P1 | Track interno Play | Autorización + Play Console |
| R1 | Revoke controlado de prueba | [REVOKE_CONTROLLED.md](REVOKE_CONTROLLED.md) |

## Requieren autorización explícita

| Acción | Doc |
|--------|-----|
| Revoke del UID documentado | [REVOKE_CONTROLLED.md](REVOKE_CONTROLLED.md) |
| Grant/revoke a clientes reales | Ticket / autorización |
| Publicar Play / App Store | Autorización + cuentas de desarrollador |

## Comandos de verificación

```powershell
cd D:\plataforma_admin
flutter analyze
flutter test

cd functions
npm test
npm run probe:negative

# Firma (rutas locales)
apksigner verify --verbose --print-certs build\app\outputs\flutter-apk\app-release.apk
keytool -printcert -jarfile build\app\outputs\bundle\release\app-release.aab
```
