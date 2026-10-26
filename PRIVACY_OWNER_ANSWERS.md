# Respuestas del propietario — Privacidad Plataforma Admin

**Estado del cuestionario:** parcialmente respondido (2026-10-25).  
**Origen de las respuestas:** declaración autorizada del propietario en chat (actualización controlada de privacidad).  
**No** constituye aprobación final de la política ni publicación.

Leyenda:

- **[RESPUESTA PROPIETARIO]** — declarado por el propietario; no es por sí solo evidencia de código.
- **[VERIFICADO EN CÓDIGO / AUDITORÍA]** — hallazgo técnico independiente.
- **[PENDIENTE]** — aún no definido o incompleto.

---

## Resumen de respuestas incorporadas

| Tema | Valor registrado | Etiqueta |
|------|------------------|----------|
| Tipo de responsable | Persona natural | [RESPUESTA PROPIETARIO] |
| Nombre | Juan Gabriel Burbano Bonifaz | [RESPUESTA PROPIETARIO] |
| País | Ecuador | [RESPUESTA PROPIETARIO] |
| Correo de privacidad | boris13jb@gmail.com | [RESPUESTA PROPIETARIO] |
| Domicilio / dirección formal | Solo país indicado; dirección física **incompleta** | [PENDIENTE] (país ≠ domicilio) |
| Personas afectadas | Operadores administrativos **y** usuarios de productos gestionados | [RESPUESTA PROPIETARIO] |
| Alcance lookup / perfil | Se mantiene por ahora el perfil completo observado en código | [RESPUESTA PROPIETARIO] + [VERIFICADO EN CÓDIGO] |
| Retención / plazos | Pendiente de determinar | [PENDIENTE] |
| Eliminación | Atención **manual**; procedimiento detallado pendiente de documentar y verificar | [RESPUESTA PROPIETARIO] + [PENDIENTE] |
| Proveedores (declaración) | Firebase (lista exacta de servicios/proyectos a contrastar con inventario) | [RESPUESTA PROPIETARIO] + contraste técnico |
| URL pública política | Pendiente | [PENDIENTE] |
| Aprobación final | Propietario | [RESPUESTA PROPIETARIO] |
| Bases jurídicas | Pendientes de análisis y confirmación | [PENDIENTE] |

---

## A. Identidad y contacto

### A1. Responsable legal
- **[RESPUESTA PROPIETARIO]:** Juan Gabriel Burbano Bonifaz.
- ¿Por qué?: identifica al responsable del tratamiento.
- Depende: `PRIVACY_POLICY_DRAFT.md` §1; ficha Play.

### A2. Tipo
- **[RESPUESTA PROPIETARIO]:** persona natural.
- Nombre comercial distinto: **[PENDIENTE]** (no indicado).

### A3. País y domicilio publicable
- País **[RESPUESTA PROPIETARIO]:** Ecuador.
- Domicilio físico / dirección formal: **[PENDIENTE]**.  
  **Nota:** el país de operación **no sustituye** una dirección de contacto publicable. Marcar domicilio como **incompleto**.

### A4. Correo de privacidad
- **[RESPUESTA PROPIETARIO]:** boris13jb@gmail.com.
- Debe revisarse antes de la aprobación final de la política publicada.

### A5. Autoridad de control
- **[PENDIENTE]** (no indicado).

---

## B. Servicio y público

### B1. Quiénes usan / personas afectadas
- **[RESPUESTA PROPIETARIO]:** operadores administrativos **y** usuarios de los productos gestionados (cuando un admin opera sobre ellos).
- Equivale a opción B del cuestionario previo.

### B2. Territorios
- País del responsable: Ecuador **[RESPUESTA PROPIETARIO]**.
- Territorios de usuarios de productos: **[PENDIENTE]**.

### B3. Público / menores
- **[PENDIENTE]** (no confirmado explícitamente en esta ronda).

### B4. Finalidades de negocio
- **[PENDIENTE]** (más allá de finalidades técnicas del inventario).

---

## C. Datos y proveedores

### C5. Datos adicionales (teléfono, facturación, docs)
- **[PENDIENTE]** en esta ronda.

### C6. Auditoría hubAuditLogs
- Declaración pública detallada: **[PENDIENTE]** explícito; el inventario técnico ya documenta su existencia **[VERIFICADO EN CÓDIGO]**.

### C7. Proveedores
- **[RESPUESTA PROPIETARIO]:** Firebase.
- **[VERIFICADO EN CÓDIGO / AUDITORÍA]** (contraste, no sustituye la declaración): Auth, Cloud Functions, Firestore hub, Admin SDK hacia proyectos de producto (p. ej. CotiApp, CV Maker); ver `PRIVACY_DATA_INVENTORY.md`.
- Otros (hosting política, correo, soporte, IA, pagos): **[PENDIENTE]** — no afirmar que Firebase es el único proveedor implicado hasta completar el contraste y la decisión del propietario.

### C8. Transferencias / DPA
- **[PENDIENTE]**.

### Lookup / perfil completo
- **[RESPUESTA PROPIETARIO]:** se mantiene por ahora la respuesta de perfil completo.
- **[VERIFICADO EN CÓDIGO]:** `cotiLookupUser` / `cvLookupUser` pueden devolver el documento `profile` completo (`functions/src/connectors/cotiapp.ts`, `cvmaker.ts`).
- Necesidad y minimización: **siguen abiertas** (ver `PRIVACY_REVIEW_PENDING.md` / remediation R3).

---

## D. Conservación, derechos, eliminación

### D9. Plazos de retención
- **[PENDIENTE DE CONFIRMACIÓN]:** pendiente de determinar (todas las categorías).

### D10. Eliminación
- **[RESPUESTA PROPIETARIO]:** atención **manual**.
- **[VERIFICADO EN CÓDIGO]:** no existe eliminación de cuenta **in-app** en el cliente Flutter (auditoría: sin `deleteUser` / `deleteAccount` en `lib/`).
- **[PENDIENTE]:** documentar y verificar el procedimiento real (pasos, responsables, verificación de identidad, plazos de respuesta, qué sistemas se tocan, limitaciones técnicas — p. ej. audits, backups, proyectos producto).
- No se ha verificado en esta actualización que el procedimiento manual esté operativo de extremo a extremo.

### D11. Borrado usuario final vs rastros en hub
- **[PENDIENTE]**.

### D12. Canal de derechos
- Canal indicado: correo **[RESPUESTA PROPIETARIO]** `boris13jb@gmail.com`.
- Plazo de respuesta: **[PENDIENTE]**.

### D13. Medidas organizativas (MFA, límite hubAdmin, etc.)
- **[PENDIENTE]**.

---

## E. Publicación y aprobación

### E14. URL HTTPS
- **[PENDIENTE]**.

### E15. Momento de publicación (antes Internal Testing / solo producción)
- **[PENDIENTE]**.

### E16. Quién aprueba
- **[RESPUESTA PROPIETARIO]:** propietario (aprobación final).
- Data safety Play: **[PENDIENTE]** si es la misma persona u otro rol.

### E17. Confirmaciones rápidas (esta ronda)
- Publicidad / venta de datos / Analytics futuro: **[PENDIENTE]** (no reconfirmados aquí).
- Autorización a actualizar borradores documentales con estas respuestas: **sí** (esta tarea).

---

## Bases jurídicas

- **[PENDIENTE DE CONFIRMACIÓN]:** pendientes de análisis y confirmación.  
- No inventar consentimiento u otras bases.

---

## Preguntas pendientes (visibles)

1. Dirección física o formal de contacto publicable (Ecuador no basta).  
2. Plazos de conservación por categoría de datos.  
3. Procedimiento detallado de eliminación manual (pasos, roles, verificación de identidad, limitaciones).  
4. Bases jurídicas aplicables.  
5. Lista cerrada de servicios/proyectos Firebase (y otros proveedores) a declarar.  
6. Transferencias internacionales / términos contractuales con Google.  
7. URL HTTPS de la política.  
8. Autoridad de control (si se menciona).  
9. Confirmación de público / menores.  
10. Efecto del borrado de usuario de producto sobre `hubAuditLogs`.  
11. Quién completa Data safety en Play y cuándo publicar.  
12. Revisión/aprobación final del texto completo por el propietario antes de publicar.
