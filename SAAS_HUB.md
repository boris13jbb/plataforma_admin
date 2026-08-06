# SaaS Hub — Super Admin unificado

Proyecto Firebase del hub: **`plataforma-admin-jb`**.

## 1. Crear el proyecto hub

1. [Firebase Console](https://console.firebase.google.com/) → Add project → `plataforma-admin-jb`.
2. Activar **Blaze** (requerido para Functions + secrets).
3. Authentication → Sign-in method → **Email/Password**.
4. Firestore → Create database (production).
5. Registrar app **Web** y copiar config.

## 2. Configurar FlutterFire

```powershell
cd D:\plataforma_admin
dart pub global activate flutterfire_cli
flutterfire configure --project=plataforma-admin-jb --platforms=web --yes --out=lib/firebase_options.dart
```

Eso reemplaza el placeholder en `lib/firebase_options.dart`.

## 3. Service accounts de cada producto

En cada proyecto de producto:

1. Firebase Console → Project settings → Service accounts → **Generate new private key**.
2. Guarda el JSON en un sitio seguro (no lo subas al git).

Secrets en el hub:

```powershell
cd D:\plataforma_admin

# JSON completo de cotiapp-saas-jb
Get-Content D:\ruta\sa-cotiapp.json -Raw | firebase functions:secrets:set SA_COTIAPP_JSON --project plataforma-admin-jb --data-file -

# JSON completo de cvmaker-saas-jb
Get-Content D:\ruta\sa-cvmaker.json -Raw | firebase functions:secrets:set SA_CVMAKER_JSON --project plataforma-admin-jb --data-file -

# Secreto bootstrap del primer hubAdmin
"TU_SECRETO_FUERTE" | firebase functions:secrets:set HUB_ADMIN_BOOTSTRAP_SECRET --project plataforma-admin-jb --data-file -
```

El service account de cada producto necesita permisos Admin en **Auth** y **Firestore** de ese proyecto (el JSON de “Firebase Admin SDK” suele bastar).

## 4. Desplegar Functions y rules

```powershell
cd D:\plataforma_admin\functions
npm install
npm run build
cd ..
firebase deploy --only functions,firestore:rules --project plataforma-admin-jb
```

Callables desplegadas:

- `bootstrapHubAdmin`
- `hubListProducts`
- `hubProductMetrics`
- `hubLookupUser`
- `hubGrant`
- `hubRevoke`
- `hubListGrants`

## 5. Primer hubAdmin

1. Crea un usuario Email/Password en Auth del hub.
2. Ejecuta la consola:

```powershell
cd D:\plataforma_admin
flutter run -d chrome
```

3. En login: email + contraseña + secreto → **Activar primer hubAdmin**.
4. Cierra sesión y vuelve a entrar (refresca el claim `hubAdmin`).

## 6. Uso diario

1. Entra al hub.
2. Elige **CotiApp** o **CV Maker**.
3. Revisa métricas.
4. Busca cliente por email/UID.
5. Otorga o revoca acceso de cortesía (motivo obligatorio).

Los grants se escriben en el Firestore del **producto** (misma forma que los paneles legacy), así que la app cliente los respeta.

## Añadir una tercera aplicación

1. **Functions**
   - Añade entry en [`functions/src/products.ts`](functions/src/products.ts).
   - Crea `functions/src/connectors/<nuevo>.ts` con metrics/lookup/grant/revoke/listGrants.
   - Declara secret `SA_<NUEVO>_JSON` en `functions/src/index.ts` y cablea `saJsonFor` + dispatch.
2. **Flutter**
   - Añade `HubProduct` en [`lib/products/product_registry.dart`](lib/products/product_registry.dart).
3. **Ops**
   - Crea SA del proyecto del producto y `firebase functions:secrets:set SA_<NUEVO>_JSON`.
   - Redeploy functions.

No copies el código de la app cliente dentro de este repo: solo el connector de administración.

## Seguridad

- Claim `hubAdmin` solo en el proyecto hub.
- Colecciones `hubAdmins`, `hubAuditLogs`, `productRegistry`: rules `false` (solo Admin SDK).
- Las apps de usuario **no** incluyen este panel.
- Limita cuántas cuentas tienen `hubAdmin` (idealmente 1–2).

## Relación con paneles legacy

| Panel | Ubicación | Estado |
|-------|-----------|--------|
| Hub unificado | `D:\plataforma_admin` | Oficial |
| CotiApp admin | `creador_cotizaciones/apps/admin_console` | Legacy (opcional) |
| CV Maker admin | `creador_cv/super_admin` | Legacy (opcional) |
