# Plan Firebase App Check — Plataforma Admin

**Estado:** plan solo. **No** hay enforcement activo ni SDK App Check en la app.
**Proyecto:** `plataforma-admin-jb`

## ¿Es adecuado?

Sí como endurecimiento **posterior** a Internal Testing estable. La app es un hub admin con callables públicas (`invoker: public`) protegidas por Auth + claim `hubAdmin`. App Check reduce abuso de invocación anónima/automatizada; **no** sustituye `assertHubAdmin`.

## Cobertura típica

| Superficie | Efecto con App Check |
|------------|----------------------|
| Cloud Functions (callables) | Puede exigir token App Check además de Auth |
| Firebase Auth | Protección opcional anti-abuso (según producto/config) |
| Firestore | Poco relevante aquí: reglas ya deniegan clientes |
| Storage / RTDB | No usados por este hub hoy |

## Proveedores recomendados

| Plataforma | Proveedor sugerido | Notas |
|------------|-------------------|--------|
| Android release / Play | **Play Integrity** | Requiere app en Play (o setup Integrity); alinear con firma Play App Signing |
| Android debug | **Debug provider** | Tokens de depuración; nunca en producción |
| iOS | **App Attest** (DeviceCheck legacy) | Requiere Mac/Xcode y app registrada |
| Web | **reCAPTCHA Enterprise** o reCAPTCHA v3 | Dominios autorizados |

## Implementación gradual (sin bloquear usuarios)

1. **Observación / monitor:** registrar App Check en consola; añadir SDK Flutter (`firebase_app_check`) e inicializar proveedores; **no** activar enforcement en Functions/Auth.
2. **Prueba interna:** testers de Internal Testing + cuentas hubAdmin verifican login y callables; revisar métricas de tokens válidos/ inválidos en Console.
3. **Enforcement selectivo:** primero Cloud Functions del hub; mantener debug tokens solo en builds de desarrollo.
4. **Reversión:** desactivar enforcement en Console (minutos); la app sigue funcionando con Auth + `hubAdmin`. No hace falta redeploy de reglas Firestore.

## Cómo evitar bloquear legítimos

- No activar enforcement el mismo día del primer upload a Play.
- Registrar el certificado correcto (upload key / Play App Signing key según lo que use Integrity).
- Separar builds debug (debug provider) de release (Play Integrity).
- Tener un operador que pueda desactivar enforcement sin redeploy de app.

## Condiciones antes de enforcement

- [ ] Internal Testing con AAB estable
- [ ] Login + callables OK con App Check en modo monitor
- [ ] Métricas de fallo de token aceptables
- [ ] Autorización explícita del propietario para enforcement

## Fuera de alcance de este documento

No se despliega Functions ni se cambia la consola desde esta auditoría.
