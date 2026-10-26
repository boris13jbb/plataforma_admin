# Política de privacidad — Plataforma Admin

> **BORRADOR NO APROBADO — NO PUBLICAR**  
> Documento preliminar. Debe ser revisado y aprobado por el propietario antes de cualquier publicación o uso en Google Play Data safety.  
> No constituye asesoramiento jurídico ni declaración de cumplimiento definitivo de la legislación ecuatoriana, del RGPD u otras normas.

**Última actualización del borrador:** 2026-10-25 (incorporación de respuestas parciales del propietario).  
**Fecha de entrada en vigor:** `[PENDIENTE DE CONFIRMACIÓN]`.  
**URL pública HTTPS:** `[PENDIENTE DE CONFIRMACIÓN]`.

Leyenda: **[VERIFICADO EN CÓDIGO]** · **[SEGÚN PROPIETARIO]** · **`[PENDIENTE DE CONFIRMACIÓN]`**

---

## 1. Identidad y contacto del responsable

**Aplicación:** Plataforma Admin.  
**Identificador Android:** `com.plataformaadmin.plataforma_admin`.

| Campo | Valor | Origen |
|-------|--------|--------|
| Responsable (nombre) | Juan Gabriel Burbano Bonifaz | [SEGÚN PROPIETARIO] — revisar antes de aprobar |
| Tipo | Persona natural | [SEGÚN PROPIETARIO] |
| País de operación | Ecuador | [SEGÚN PROPIETARIO] |
| Dirección / domicilio de contacto publicable | `[PENDIENTE DE CONFIRMACIÓN]` — el país no sustituye una dirección formal | |
| Correo de privacidad | boris13jb@gmail.com | [SEGÚN PROPIETARIO] — revisar antes de aprobar |
| Autoridad de control | `[PENDIENTE DE CONFIRMACIÓN]` | |

---

## 2. Categorías de personas cuyos datos se tratan

Según el propietario, esta política contempla:

1. **Operadores administrativos** del hub (cuentas que inician sesión en Plataforma Admin).  
2. **Usuarios de los productos gestionados** (p. ej. CotiApp, CV Maker), cuando un operador autorizado consulta o modifica datos relacionados con su cuenta o accesos desde el hub.

[SEGÚN PROPIETARIO]. El detalle técnico de esos flujos está en `PRIVACY_DATA_INVENTORY.md` **[VERIFICADO EN CÓDIGO]**.

Público objetivo / menores: `[PENDIENTE DE CONFIRMACIÓN]`.

---

## 3. Categorías de datos

### 3.1 Operadores [VERIFICADO EN CÓDIGO]

- Correo electrónico y contraseña (la contraseña se transmite al servicio de autenticación; la aplicación no la almacena en un almacén propio de la app).  
- Identificador de usuario (UID) y datos de sesión.  
- Indicador de rol administrativo (`hubAdmin`) en el token.  
- Registros administrativos asociados (p. ej. documento en `hubAdmins` cuando aplica).

### 3.2 Usuarios de productos (cuando un operador actúa) [VERIFICADO EN CÓDIGO]

- Identificadores y correo usados en la búsqueda.  
- Datos de cuenta del producto (p. ej. uid, email, displayName, estado).  
- **Perfil:** la operación de lookup puede devolver el **documento de perfil completo** almacenado en el producto (no se presenta aquí como minimizado). El propietario ha indicado mantener este alcance por ahora [SEGÚN PROPIETARIO]; la necesidad de ese alcance sigue sujeta a revisión operativa.  
- Entitlements / grants, usage (según producto) y metadatos de operaciones administrativas.

### 3.3 Auditoría [VERIFICADO EN CÓDIGO]

- Registros en el hub (`hubAuditLogs`) con acción, actor, producto y objetivos (p. ej. email/UID).  
- Registros relacionados en los proyectos de producto cuando las operaciones de grant/revoke los escriben.

### 3.4 Lo no observado en el cliente

No se hallaron SDK de Analytics, Crashlytics ni publicidad en las dependencias Flutter actuales.  
**Eso no implica** que no exista tratamiento de datos: hay autenticación, Functions, Firestore y datos de producto. Tampoco implica ausencia de registros técnicos del proveedor de infraestructura.

---

## 4. Finalidades del tratamiento

**Finalidades técnicas observadas [VERIFICADO EN CÓDIGO]:**

- Autenticar a operadores y mantener la sesión.  
- Autorizar el acceso a funciones administrativas.  
- Consultar información de usuarios de productos y gestionar permisos/accesos de cortesía.  
- Registrar auditoría de acciones administrativas.  
- Permitir la operación del hub sobre productos conectados.

**Finalidades de negocio adicionales / bases jurídicas:** `[PENDIENTE DE CONFIRMACIÓN]` — no se inventan bases (incluido el consentimiento como solución universal).

---

## 5. Autenticación y acceso administrativo

[VERIFICADO EN CÓDIGO]

- Inicio de sesión con correo y contraseña mediante Firebase Authentication.  
- La interfaz muestra el panel administrativo solo si el token incluye el claim `hubAdmin`.  
- Las operaciones sensibles se validan también en el servidor (`assertHubAdmin`).  
- Las reglas de Firestore del hub en el repositorio deniegan el acceso directo del cliente a colecciones administrativas; **no se afirma aquí** que las reglas remotas desplegadas coincidan con las locales sin verificación en Console.  
- El panel de bootstrap no se muestra en builds release; la callable de bootstrap puede seguir existiendo en el backend con sus propios controles.

---

## 6. Consultas de perfiles, permisos y auditoría

[VERIFICADO EN CÓDIGO] + [SEGÚN PROPIETARIO]

- **Lookup:** puede devolver perfiles completos; alcance mantenido por ahora según el propietario; no se describe como minimizado.  
- **Grant / revoke / listados / métricas:** operan sobre datos de producto y dejan rastro de auditoría según el código.  
- Revisar necesidad del perfil completo sigue siendo una decisión operativa pendiente (ver `PRIVACY_REVIEW_PENDING.md`).

---

## 7. Firebase y proyectos de productos

El propietario declara **Firebase** como proveedor [SEGÚN PROPIETARIO].

Según el inventario técnico [VERIFICADO EN CÓDIGO], intervienen de forma observable, entre otros:

- Firebase Authentication, Cloud Functions y Cloud Firestore en el proyecto hub configurado en el cliente (`plataforma-admin-jb`).  
- Acceso mediante Admin SDK a proyectos Firebase de productos conectados (p. ej. CotiApp, CV Maker), usando secretos de servicio en Functions.

**No se afirma** que Firebase sea el único proveedor implicado hasta completar el contraste de servicios, hosting de esta política, correo u otros encargados: `[PENDIENTE DE CONFIRMACIÓN]`.

Referencia pública de privacidad de Google (terceros): https://policies.google.com/privacy  

Ubicaciones exactas de almacenamiento y transferencias internacionales detalladas: `[PENDIENTE DE CONFIRMACIÓN]` (requieren confirmación contractual/técnica del propietario; no se inventan).

---

## 8. Seguridad

Medidas técnicas observadas [VERIFICADO EN CÓDIGO]: autenticación Firebase; autorización `hubAdmin` en servidor; denegación de acceso cliente a datos admin en rules del repositorio; tráfico sin cleartext HTTP en la configuración Android de la app; bootstrap oculto en la UI release.

Medidas organizativas adicionales (MFA, límites de cuentas, etc.): `[PENDIENTE DE CONFIRMACIÓN]`.  
No se garantiza seguridad absoluta ni cifrado en reposo sin evidencia específica adicional.

---

## 9. Conservación y eliminación

**Conservación (plazos):** `[PENDIENTE DE CONFIRMACIÓN]` — el propietario indica que la retención está pendiente de determinar.

**Eliminación:**

- **No** existe función de borrado de cuenta **dentro de la aplicación** [VERIFICADO EN CÓDIGO].  
- El propietario indica **atención manual** de solicitudes [SEGÚN PROPIETARIO].  
- El procedimiento detallado (pasos, responsables, verificación de identidad, sistemas afectados, plazos) está **pendiente de documentar y verificar** `[PENDIENTE DE CONFIRMACIÓN]`.  
- **No** se afirma que toda solicitud de eliminación pueda cumplirse de inmediato: pueden existir limitaciones técnicas o legales (p. ej. registros de auditoría, copias de seguridad, datos en proyectos de producto) que requieren evaluación caso a caso.

Canal de contacto para solicitudes: el correo de privacidad indicado en la sección 1 (revisar antes de aprobar).

---

## 10. Derechos y solicitudes

Según la legislación que resulte aplicable (evaluación pendiente), los interesados pueden disponer de derechos de acceso, rectificación, eliminación u otros.

**Cómo solicitarlo (borrador):** enviar un correo a boris13jb@gmail.com [SEGÚN PROPIETARIO], identificando la cuenta o el producto afectado. Podrá solicitarse información razonable para verificar la identidad.

**Plazo de respuesta:** `[PENDIENTE DE CONFIRMACIÓN]`.  
La atención se describe como **manual**; no se promete un flujo automatizado in-app.

---

## 11. Proveedores y transferencias internacionales

Ver sección 7. Lista cerrada de destinatarios y transferencias: `[PENDIENTE DE CONFIRMACIÓN]`.  
No se declaran transferencias concretas inventadas.

---

## 12. Cambios y vigencia

Podremos actualizar esta política cuando cambien las prácticas o la normativa. La versión publicada en la URL oficial prevalecerá.  
Forma de aviso: `[PENDIENTE DE CONFIRMACIÓN]`.  
Vigencia: `[PENDIENTE DE CONFIRMACIÓN]`.

---

## Contacto

Privacidad: boris13jb@gmail.com [SEGÚN PROPIETARIO — pendiente de confirmación final para publicación].

---

## Aviso final

**BORRADOR NO APROBADO — NO PUBLICAR.**  
Aprobación final: propietario [SEGÚN PROPIETARIO].  
Hasta completar domicilio, plazos, procedimiento de eliminación, bases jurídicas, URL y contraste de proveedores, este texto no debe usarse como política publicada ni como base única de Data safety.
