# Inventario de datos — Plataforma Admin

**Propósito:** ciclo de vida trazable para política y Data safety.  
**No** es política legal.  
**Actualizado:** 2026-10-25 (auditoría integral + vínculo a respuestas parciales del propietario).

Estados: **Confirmado** · **Parcial** · **Inferido** · **Pendiente propietario** · **No encontrado**

Documentos: `PRIVACY_TECHNICAL_AUDIT.md`, `PRIVACY_OWNER_ANSWERS.md`, `PRIVACY_POLICY_DRAFT.md` (**BORRADOR NO APROBADO — NO PUBLICAR**), `PRIVACY_REVIEW_PENDING.md`.

### Vinculación con respuestas del propietario (no son evidencia técnica)

Las respuestas del propietario (identidad, correo, Ecuador, alcance operadores+usuarios de productos, retención pendiente, eliminación manual, proveedor declarado “Firebase”, URL pendiente, bases jurídicas pendientes) están en `PRIVACY_OWNER_ANSWERS.md`.  
**No** convierten por sí solas una fila de este inventario en “cumplida” ni demuestran despliegue remoto.  
El hallazgo de **lookup con perfil completo** sigue **Confirmado** en código; el propietario indica mantener ese alcance por ahora (minimización aún abierta).  
La ausencia de Analytics/Crashlytics/Ads en el cliente **no** implica ausencia de recopilación de datos (Auth, Functions, perfiles, auditoría).  
Las rules de Firestore **remotas** no se afirman idénticas a las locales sin comprobación en Console.

---

## Diagrama de flujo (resumen)

Operador → Login (email/password) → Firebase Auth hub → UI (si hubAdmin) → Callables → Functions → (opcional) Auth/Firestore producto → respuesta UI + hubAuditLogs.

---

## Tabla de inventario

| ID | Dato / categoría | Origen | Evidencia | Finalidad técnica | ¿Vinculable a persona? | Destino | Destinatarios | Conservación | Eliminación | Estado |
|----|------------------|--------|-----------|-------------------|------------------------|---------|---------------|--------------|-------------|--------|
| D01 | Email operador | Input login | `lib/features/login/login_screen.dart:119-135`; `lib/hub/hub_session.dart:45-52` | Autenticación | Sí | Firebase Auth hub | Google/Firebase | Pendiente propietario | Pendiente propietario | Confirmado |
| D02 | Contraseña operador | Input login | `hub_session.dart:50-52` | Autenticación | Sí (secreto) | Firebase Auth (tránsito SDK) | Google/Firebase | No en app | N/A app | Confirmado (app no persiste) |
| D03 | UID operador | Auth SDK | `hub_session.dart:22-33`; dashboard `dashboard_screen.dart:74-76` | Sesión / UI | Sí | Token/sesión; UI | Firebase; dispositivo (sesión) | Sesión SDK | Sign-out / borrar Auth (manual) | Confirmado |
| D04 | Claim `hubAdmin` | Token claims | `hub_session.dart:32-36`; `functions/src/hubAuth.ts:15-19` | Autorización | Sí (rol) | ID token | Cliente + Functions | Mientras claim exista | Admin SDK / script | Confirmado |
| D05 | Secreto bootstrap | Input (UI debug/profile) | `bootstrap_admin_panel.dart`; `hub_api_client.dart:27-28`; `bootstrapGate.ts:17-18` | Primer admin | No (secreto ops) | Callable `bootstrapHubAdmin` | Solo servidor | No en cliente | N/A | Confirmado |
| D06 | Registro hubAdmins | Backend bootstrap/script | `functions/src/index.ts:51-56` | Catálogo admins | Sí | Firestore hub `hubAdmins` | Solo Admin SDK (rules deny) | Pendiente propietario | Pendiente propietario | Confirmado |
| D07 | productId / plan / reason | UI admin | `hub_api_client.dart:61-76`; `product_admin_screen.dart` | Grant/ops | Parcial (reason libre) | Callables | Functions | En audits | Pendiente | Confirmado |
| D08 | Email/UID usuario producto (búsqueda) | Input operador | `hub_api_client.dart:50-58` | Lookup | Sí | Callable → producto Auth | Functions + proyecto producto | En audits + producto | Pendiente | Confirmado |
| D09 | Perfil producto (documento `users`) | Backend lookup | `cotiapp.ts:75-85`; `cvmaker.ts:115-126` | Mostrar ficha | Sí (contenido variable) | Respuesta a app hub | Operador hubAdmin | Memoria UI | No borrado hub | Confirmado (perfil completo posible; propietario mantiene alcance por ahora — no minimizado) |
| D10 | Entitlements / grants producto | Backend | `cotiapp.ts:125-154` etc. | Cortesía/planes | Sí | Firestore producto | Proyecto producto | Pendiente | Revoke parcial | Confirmado |
| D11 | Usage CV Maker | Backend | `cvmaker.ts:106-129` | Métricas uso | Sí (por uid) | Respuesta UI | Operador | Memoria UI | N/A hub | Confirmado |
| D12 | hubAuditLogs | Functions | `hubAuth.ts:27-33`; `index.ts:58-62,147-154,179-183` | Auditoría | Sí (actor + target) | Firestore hub | Solo Admin SDK | **Pendiente propietario** (retención no determinada) | Atención manual declarada; procedimiento **pendiente** de documentar/verificar; **sin** delete in-app | Confirmado existencia; eliminación parcial/pendiente |
| D13 | Audits en producto | Connectors grant/revoke | p.ej. `cotiapp.ts:156-159` `actorEmail` | Auditoría producto | Sí | Firestore producto | Proyecto producto | Pendiente | Pendiente | Confirmado |
| D14 | Métricas agregadas | Connectors metrics | callables metrics | Supervisión | Suele agregada; `recentErrors` puede incluir datos | Respuesta UI | Operador | Memoria UI | N/A | Parcial (revisar campos error reports) |
| D15 | ProjectId / apiKey cliente Firebase | Config | `lib/firebase_options.dart` | Conectar SDK | No PII típico; identificadores de proyecto | App embebida | Google | Vida de la app | N/A | Confirmado (claves de cliente, no secretos de servidor) |
| D16 | Service account JSON producto | Secret Manager | `index.ts:12-13` `defineSecret` | Admin SDK multi-proyecto | Credencial | Functions runtime | Google SM | Ops | Rotación pendiente propietario | Confirmado nombre; **valor no inspeccionado** |
| D17 | Analytics/Ads IDs | — | `pubspec.yaml` sin SDKs | — | — | — | — | — | — | No encontrado en dependencias cliente |
| D18 | Ubicación / cámara / contactos | — | Manifiesto solo INTERNET | — | — | — | — | — | — | No encontrado en manifiesto fuente |
| D19 | Backup dispositivo Android | Default platform | Manifiesto sin `allowBackup=false` | Posible backup de datos app | Inferido | Backup Android | Usuario/dispositivo | Inferido | Inferido | Inferido |

---

## Tabla de evidencias (afirmaciones clave)

| Afirmación | Fuente | Evidencia | Limitación | Confianza | Próximo paso |
|------------|--------|-----------|------------|-----------|--------------|
| Login email/password | Código | `hub_session.dart:50-52` | — | Alta | — |
| UI exige hubAdmin | Código | `main.dart:83-89` | — | Alta | — |
| Server exige hubAdmin | Código | `hubAuth.ts:9-24` | Deploy remoto no verificado aquí | Alta código | Confirmar deploy |
| Cliente no lee Firestore hub | Rules | `firestore.rules:5-16` | ¿Rules desplegadas? | Alta código | Verificar Console |
| Lookup expone profile completo | Código | `cotiapp.ts:83-84` | Campos reales varían por doc | Alta | Minimizar campos |
| Sin delete account in-app | Búsqueda | Sin matches en `lib/` | Podría existir proceso manual | Alta no-encontrado | Definir procedimiento |
| Sin Analytics en app | pubspec | deps 30-40 | Telemetría infra Google posible | Alta deps | Confirmar propietario |
| Bootstrap oculto en release | Código | `bootstrap_admin_panel.dart:9` | Callable sigue activa | Alta | Decisión ops |

---

## Colecciones / entidades

### Hub (`plataforma-admin-jb`)

| Entidad | Campos relevantes | Acceso cliente |
|---------|-------------------|----------------|
| Auth users | email, uid, claims | Propio vía SDK |
| `hubAdmins/{uid}` | uid, email, timestamps, createdBy | Deny (`firestore.rules:5-7`) |
| `hubAuditLogs/{id}` | action, actorUid, productId, targets, createdAt | Deny |
| `productRegistry` | registry | Deny |

### Producto (vía Admin SDK)

| Entidad (observada en connectors) | Notas |
|------------------------------------|-------|
| Auth user | email, displayName, disabled |
| `users/{uid}` | profile arbitrario |
| `entitlements/{uid}` | plan, grant metadata |
| `platformGrants` / grants CV | historial grants |
| `usage/{uid}` (CV) | resumeCount |
| audits producto | actorEmail, target |

---

## Preguntas al propietario (por dato)

Ver `PRIVACY_OWNER_ANSWERS.md` (plazos D01/D06/D12, borrado, cobertura usuarios producto, Data safety).
