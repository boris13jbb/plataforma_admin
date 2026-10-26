# Gestión de hubAdmin (operaciones)

Proyecto: `plataforma-admin-jb`. Claim estricto: `hubAdmin === true`.

## UI de bootstrap en la app (opción B)

- En builds **release** (`kReleaseMode`) el panel `BootstrapAdminPanel` **no se muestra** (login ni pantalla sin permiso).
- En **debug/profile** el panel sigue disponible (colapsado) para inicialización controlada en entorno de desarrollo.
- **Ocultar la UI no desactiva** la callable `bootstrapHubAdmin` en Cloud Functions. La seguridad sigue siendo: Auth + secreto de servidor + colección `hubAdmins` vacía.
- No trates la ausencia del panel en Play/APK release como un control de autorización.

Flag de código: `showHubBootstrapUi` → `!kReleaseMode` en `lib/features/login/bootstrap_admin_panel.dart`.

## Cómo se crea el primer admin

### Condiciones del backend (siempre)

Callable `bootstrapHubAdmin`:

1. Usuario autenticado en el hub.
2. Secreto `HUB_ADMIN_BOOTSTRAP_SECRET` válido (solo en servidor; no va al cliente embebido).
3. Colección `hubAdmins` vacía.
4. Si ya hay un admin → `failed-precondition` (no promueve a terceros).

### Inicialización controlada (recomendado)

Cuando **aún no** existe ningún `hubAdmin`:

1. Usar un build **debug/profile** de la app (o herramienta Admin SDK), no el AAB de Play.
2. Crear/iniciar sesión con la cuenta que será el primer admin.
3. Completar el panel avanzado de bootstrap (solo visible fuera de release).
4. Cerrar sesión y volver a entrar para refrescar el token.
5. Verificar claim y acceso al dashboard.

Alternativa privilegiada (sin UI): Firebase Admin SDK / script `functions/scripts/set-hub-admin.js` — **solo con autorización explícita** y ADC/credenciales de proyecto. No pegar secretos en chats.

## Recuperación si no queda ningún hubAdmin

Si se pierde el acceso administrativo (sin cuentas con claim `hubAdmin`):

1. Confirmar en Firebase Auth/Firestore (consola o Admin SDK) el estado de claims y de `hubAdmins`.
2. Con acceso privilegiado al proyecto `plataforma-admin-jb`:
   - Restaurar claim `hubAdmin: true` en el UID operador.
   - Asegurar documento `hubAdmins/{uid}` coherente.
   - Registrar auditoría si aplica.
3. Si la colección `hubAdmins` está vacía **y** se decide reutilizar bootstrap: callable sigue disponible en backend; la UI release **no** la ofrece — usar debug/profile o Admin SDK.
4. Controles previos: autorización humana, cuenta correcta, no rotar secretos en el chat, no ejecutar grants/revokes de productos como parte de la recuperación.

Script de referencia (mutación real): `functions/scripts/set-hub-admin.js` — requiere autorización independiente.

## Añadir admins adicionales (ya existe al menos uno)

No hay callable pública de “promover hubAdmin”. Usar Admin SDK / script controlado. Limitar a 1–2 cuentas. No quitar el claim del admin principal para pruebas negativas en producción.

## Operaciones sensibles (productos)

Todas pasan por callables con `assertHubAdmin`:

`hubListProducts`, `hubProductMetrics`, `hubLookupUser`, `hubGrant`, `hubRevoke`, `hubListGrants`.

Revoke de prueba: [REVOKE_CONTROLLED.md](REVOKE_CONTROLLED.md) — requiere autorización explícita.

## Opción C (fuera de esta tarea)

Deshabilitar o rotar el bootstrap en producción implica cambio remoto / deploy autorizado — **no** forma parte de la opción B.
