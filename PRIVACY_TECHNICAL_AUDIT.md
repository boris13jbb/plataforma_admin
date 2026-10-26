# Auditoría técnica de privacidad — Plataforma Admin

**Fecha:** 2026-10-25  
**Repositorio local:** `D:\plataforma_admin`  
**Remoto verificado:** `https://github.com/boris13jbb/plataforma_admin.git`  
**Rama:** `main`  
**Alcance:** revisión estática de código y configuración local + tests locales.  
**No es asesoramiento jurídico. No se publicó ni desplegó nada.**

---

## 1. Resumen ejecutivo

Plataforma Admin es un hub Flutter + Firebase para operadores con claim `hubAdmin`. Recoge credenciales de operadores, transmite operaciones administrativas a Cloud Functions (`us-central1`) y, desde el backend, lee/modifica datos de usuarios en proyectos Firebase de productos (CotiApp, CV Maker). No se observaron Analytics, Ads ni eliminación de cuenta in-app.

**Veredicto técnico:** listo para revisión humana de privacidad; **no** listo para publicar política sin completar identidad legal, plazos, URL y Data safety.

---

## 2. Alcance y limitaciones

| Incluido | Excluido / no verificado |
|----------|---------------------------|
| `lib/`, `functions/src/`, `android/` manifiesto, `firestore.rules`, `firebase.json`, `pubspec.yaml`, docs privacidad | Consola Firebase/Play en vivo, datos reales de producción |
| `flutter analyze` / `flutter test` / `functions npm test` | Pruebas E2E de borrado, backups, logs cloud |
| Inventario con referencias de archivo | Contratos con Google, retención real de backups Google |

---

## 3. Arquitectura (diagrama textual)

```
[Operador]
   │  email/password
   ▼
[Flutter App: Android / Web / iOS config]
   │  Firebase Auth SDK  +  Cloud Functions HTTPS (us-central1)
   ▼
[Firebase proyecto hub: plataforma-admin-jb]
   ├─ Authentication (operadores)
   ├─ Firestore: hubAdmins, hubAuditLogs, productRegistry (cliente: deny-all)
   └─ Cloud Functions gen2
         │  Admin SDK + secrets SA_*
         ▼
[Proyectos Firebase producto: CotiApp / CV Maker]
   └─ Auth users, users/, entitlements/, grants, usage, audits producto
```

---

## 4. Metodología

1. Inventario de archivos y dependencias.  
2. Seguimiento de formularios → Auth / callables → connectors → Firestore producto.  
3. Revisión de reglas, permisos Android, ausencia de SDK de analítica.  
4. Revisión de docs de privacidad existentes.  
5. Tests locales (analyze/test).  
6. Clasificación Verificado / Inferido / Pendiente propietario / No encontrado.

---

## 5. Hallazgos verificables (privacidad / seguridad)

| ID | Severidad | Hallazgo | Evidencia | Estado |
|----|-----------|----------|-----------|--------|
| P-01 | Medio | Lookup de producto devuelve `profile` completo del documento Firestore | `functions/src/connectors/cotiapp.ts:75-85`, `cvmaker.ts:115-126` | Confirmado |
| P-02 | Medio | Auditoría hub guarda `targetEmail` / UIDs | `functions/src/index.ts:147-154`, `179-183` | Confirmado |
| P-03 | Medio | Bootstrap callable sigue activa (`invoker: public`); UI oculta solo en release | `functions/src/index.ts:17-18,37-68`; `lib/features/login/bootstrap_admin_panel.dart:9` | Confirmado |
| P-04 | Medio | Sin flujo de eliminación de cuenta en la app | Búsqueda en `lib/`: sin `deleteUser`/`deleteAccount` | No encontrado en cliente |
| P-05 | Bajo | `android:allowBackup` no declarado (default Android suele permitir backup) | `android/app/src/main/AndroidManifest.xml:1-29` | Inferido (comportamiento default) |
| P-06 | Bajo | Script operativo con fallbacks de UID/email de operador | `functions/scripts/set-hub-admin.js` | Confirmado (no reproducir valores) |
| P-07 | Info | Callables con `invoker: public`; authz en código | `functions/src/index.ts:17-18` + `assertHubAdmin` | Confirmado; diseño intencional |
| P-08 | Info | Sin Analytics/Crashlytics/Ads en `pubspec.yaml` | `pubspec.yaml:30-40` | Confirmado en dependencias |

---

## 6. Inventario (resumen)

Ver detalle en `PRIVACY_DATA_INVENTORY.md`.

Categorías principales: cuenta operador; claim hubAdmin; consultas/grants sobre usuarios de producto; auditoría hub y producto; secretos operativos (no PII de usuario final).

---

## 7. Autenticación y almacenamiento

- Auth: Email/Password Firebase (`firebase.json` auth emailPassword; `hub_session.dart:50-52`).  
- Gate UI: autenticado + `hubAdmin` (`main.dart:83-89`).  
- Server: `assertHubAdmin` estricto (`hubAuth.ts:9-24`).  
- Firestore hub: deny-all cliente (`firestore.rules`).  
- Sesión: SDK Auth (persistencia por plataforma — detalle de almacenamiento local: **Inferido**/SDK).  
- Eliminación cuenta: **No encontrado** in-app; procedimiento **Pendiente del propietario**.

---

## 8. Servicios externos

| Servicio | Evidencia | Datos aparentes | Figura contractual |
|----------|-----------|-----------------|-------------------|
| Firebase Auth/Functions/Firestore (hub) | `firebase_options.dart`, `hub_api_client.dart` | Credenciales operador, tokens, auditoría | Pendiente jurídico (encargado típico) |
| Firebase proyectos producto | connectors + secrets `SA_*` | Perfiles, entitlements, usage | Pendiente jurídico |
| GitHub (código) | remoto git | Código fuente; no tráfico de usuarios finales de la app | Hosting de código, no flujo runtime |
| Google Play (futuro) | docs/release | Distribución APK/AAB | Pendiente |

---

## 9. Riesgos y recomendaciones priorizadas

Ver `PRIVACY_REMEDIATION_PLAN.md`.

Prioridad alta humana: identidad legal, URL política, plazos, Data safety, procedimiento de borrado.  
Prioridad técnica media: minimizar payload de lookup; `allowBackup="false"` si se confirma riesgo; valorar App Check / endurecer bootstrap.

---

## 10. Pruebas ejecutadas en esta auditoría

| Prueba | Resultado |
|--------|-----------|
| `flutter analyze` | No issues found |
| `flutter test` | 12 passed |
| `cd functions && npm test` | 12 passed (ver terminal de corrida) |

No se consultaron datos reales de producción.

---

## 11. Referencias técnicas

- Flutter / Firebase Auth / Cloud Functions en código citado.  
- Google Privacy Policy (terceros): https://policies.google.com/privacy (consulta 2026-10-25).  
- Play Data safety / account deletion: documentación oficial Play Console — aplicación concreta **Pendiente** según ficha.
