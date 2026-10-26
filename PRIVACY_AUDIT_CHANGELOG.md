# Changelog — Auditoría integral de privacidad

## 2026-10-25 — Actualización controlada con respuestas del propietario

**Origen:** respuestas autorizadas del propietario (persona natural; nombre; Ecuador; correo de privacidad; alcance operadores + usuarios de productos; lookup perfil completo mantenido; retención pendiente; eliminación manual con procedimiento pendiente; proveedor declarado Firebase a contrastar; URL pendiente; aprobación = propietario; bases jurídicas pendientes).

| Documento | Cambio |
|-----------|--------|
| `PRIVACY_OWNER_ANSWERS.md` | Incorporación de respuestas; sección de pendientes; distinción respuesta vs código |
| `PRIVACY_POLICY_DRAFT.md` | Borrador actualizado; marca **BORRADOR NO APROBADO — NO PUBLICAR**; sin inventar domicilio/plazos/bases |
| `PRIVACY_REVIEW_PENDING.md` | 12 pendientes mínimos + riesgos operativos |
| `PRIVACY_DATA_INVENTORY.md` | Vínculo a respuestas sin convertirlas en evidencia técnica; D09/D12 anotados |
| `PRIVACY_AUDIT_CHANGELOG.md` | Esta entrada |

**Pendientes que siguen abiertos:** domicilio formal, plazos, SOP de eliminación, bases jurídicas, contraste de proveedores, URL HTTPS, aprobación final, Data safety, requisitos Play de borrado de cuenta, coherencia política↔app.

**No realizado:** cambios de código, deploy, publicación de política, envío de Data safety, commit/push.

---

## 2026-10-25 — Auditoría integral inicial

## Archivos creados

| Archivo | Acción |
|---------|--------|
| `PRIVACY_TECHNICAL_AUDIT.md` | Creado — informe técnico |
| `PRIVACY_REMEDIATION_PLAN.md` | Creado — plan de correcciones |
| `PRIVACY_AUDIT_CHANGELOG.md` | Creado — este registro |

## Archivos actualizados (sobrescritura documental controlada)

| Archivo | Acción |
|---------|--------|
| `PRIVACY_DATA_INVENTORY.md` | Reescrito con inventario trazable y evidencias |
| `PRIVACY_OWNER_ANSWERS.md` | Ampliado (cuestionario); **sin respuestas del propietario** (plantilla) |
| `PRIVACY_POLICY_DRAFT.md` | Alineado a hallazgos; pendientes marcados |
| `PRIVACY_REVIEW_PENDING.md` | Checklist + bloqueos de la auditoría |

## No modificados (código / infra)

- `lib/**`, `functions/src/**` (lógica runtime)  
- `firestore.rules`  
- Firebase / Play / DNS  
- Keystore / `key.properties`  
- Sin commit, push, deploy, publicación

## No ejecutado / no verificable

- Inspección de Consola Firebase (rules desplegadas, retención backups)  
- Play Console Data safety  
- Pruebas con datos reales de usuarios  
- Clonado fresco desde GitHub (se usó copia de trabajo local con remoto verificado)  
- Revisión jurídica formal LOPDP Ecuador / RGPD

## Tests en la auditoría

- `flutter analyze` — OK  
- `flutter test` — 12 passed  
- `functions npm test` — 12 passed  
