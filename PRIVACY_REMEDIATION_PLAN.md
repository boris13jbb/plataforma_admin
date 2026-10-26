# Plan de correcciones — Privacidad / seguridad (Plataforma Admin)

**Fecha:** 2026-10-25  
**Estado:** propuestas — **no aplicadas** en esta auditoría (salvo documentación).  
**Sin deploy / sin publicación.**

| ID | Prioridad | Corrección | Archivos | Mitiga | Pruebas / aceptación | Esfuerzo |
|----|-----------|------------|----------|--------|----------------------|----------|
| R1 | Alta (humana) | Completar identidad legal, correo, país, URL HTTPS, aprobación | `PRIVACY_OWNER_ANSWERS.md` → política | Bloqueo publicación / Play | Campos sin `[PENDIENTE]` críticos | Bajo (humano) |
| R2 | Alta (humana) | Definir plazos retención y borrado de cuenta operador + efecto en logs | Política + ops | Derechos / Play account deletion | Procedimiento escrito y ejecutable | Medio |
| R3 | Media (código) | Minimizar respuesta de `lookupUser` (no devolver `profile` completo; whitelist de campos) | `functions/src/connectors/cotiapp.ts`, `cvmaker.ts` | P-01 minimización | Tests connectors + smoke lookup | Medio |
| R4 | Media (Android) | Declarar `android:allowBackup="false"` (o reglas de exclusión) si se confirma riesgo de backup de sesión | `AndroidManifest.xml` | P-05 | Rebuild APK; verificar manifiesto | Bajo |
| R5 | Media (ops) | Decidir endurecimiento bootstrap (rotar secreto / monitor App Check / opción C) | Functions + docs | P-03 | Sin romper primer-admin recovery | Medio |
| R6 | Baja | Evitar defaults de email/UID en scripts versionados; solo env vars | `functions/scripts/set-hub-admin.js` | P-06 | Script falla sin env | Bajo |
| R7 | Baja / post-IT | App Check en modo monitor → enforcement gradual | App + Console | Abuso callables | Plan `APP_CHECK.md` | Medio |
| R8 | Info | Confirmar rules Firestore desplegadas = repo | Console | Drift seguridad | Diff rules Console vs repo | Bajo |

### Criterios de aceptación globales

- No debilitar `assertHubAdmin` ni rules deny-all.  
- No desplegar sin autorización.  
- Tras cambios de código: `flutter analyze`, `flutter test`, `functions npm test`, rebuild release si afecta artefacto.
