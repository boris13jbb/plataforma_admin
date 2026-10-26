# Procedimiento de revoke controlado

**Estado:** preparado — **no ejecutado** en esta fase.
Requiere autorización explícita antes de modificar entitlements reales.

## Objetivo

Revocar un acceso de cortesía otorgado por el hub, con auditoría verificable,
sin tocar la cuenta administrativa principal ni clientes no autorizados.

## Candidato observado (evidencia previa, no ejecutar aún)

Fuente: `hubAuditLogs` (2026-10-25), acción `grant`:

| Campo | Valor |
|-------|--------|
| Proyecto destino | `cotiapp-saas-jb` (`productId=cotiapp`) |
| Target email | `boris13jb@gmail.com` (cuenta **en el producto** CotiApp) |
| Target UID (CotiApp) | `Qoz26STj7CVPMzEI8XMTTTpTFky1` |
| Plan otorgado | `business` |
| Actor hub | UID hubAdmin del operador (claim en `plataforma-admin-jb`) |
| Motivo | `Acceso cortesía / piloto (hub)` |

> El email puede coincidir con el operador del hub, pero el UID es del proyecto
> producto. Confirmar en la UI con **Buscar** antes de revocar.

## Precondiciones

1. Operador autenticado con `hubAdmin` en el hub.
2. Autorización explícita por escrito para revocar ese UID/email.
3. App actualizada (candado `AsyncGuard` anti doble envío).
4. Conexión a Internet (callables remotas).

## Pasos (manual, tras autorización)

1. Abrir Plataforma Admin → **CotiApp**.
2. Buscar `Qoz26STj7CVPMzEI8XMTTTpTFky1` o el email de prueba autorizado.
3. Verificar plan/source actuales en la tarjeta de usuario.
4. Pulsar **Revocar** una sola vez (botón se deshabilita mientras `_busy`).
5. Esperar snackbar «Acceso revocado».
6. Confirmar en UI: plan `free` / source `admin_revoke` (o equivalente del connector).
7. Confirmar en Firestore hub: nuevo `hubAuditLogs` con `action=revoke`, mismo `productId` y `targetUid`.
8. (Opcional) Confirmar en CotiApp `platformGrants/{grantId}.revokedAt` no nulo.

## Comprobaciones negativas (sin revoke)

- Segundo tap durante la operación: no debe generar segundo audit `revoke`.
- Sin usuario seleccionado: el botón no debe invocar callable.
- Sin `hubAdmin`: callable debe responder `permission-denied` (ver pruebas unitarias + sonda HTTP).

## Qué NO hacer

- No revocar UIDs de clientes de producción sin ticket.
- No quitar el claim `hubAdmin` de la cuenta principal para “probar”.
- No borrar documentos de entitlements a mano en Console.
- No ejecutar este procedimiento desde scripts no revisados.

## Frase de autorización sugerida

> «Autorizo revoke en cotiapp del UID Qoz26STj7CVPMzEI8XMTTTpTFky1 (prueba).»

Cuando exista esa autorización, el agente o el operador puede ejecutar solo ese revoke.
