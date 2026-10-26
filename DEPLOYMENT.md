# Despliegue remoto — Plataforma Admin

El hub ya está diseñado para acceso desde cualquier lugar: la UI (web o app nativa)
habla con **Firebase Auth + Cloud Functions (HTTPS)** del proyecto `plataforma-admin-jb`.
No se expone la base de datos a Internet; Firestore del hub tiene rules `allow … if false`
y solo Admin SDK / Functions escriben.

## Componentes

| Componente | Tecnología | Ubicación |
|------------|------------|-----------|
| API | Cloud Functions gen2 callables | `us-central1` |
| Auth | Firebase Auth Email/Password | proyecto hub |
| Datos hub | Firestore `(default)` nam5 | rules deniegan clientes |
| Datos producto | Firestore de CotiApp / CV Maker vía SA | multi-proyecto |
| UI Web | Flutter Web | build en `build/web` |
| UI móvil | Flutter Android / iOS | stores / sideload |

## Callables desplegadas

- `bootstrapHubAdmin`
- `hubListProducts`
- `hubProductMetrics`
- `hubLookupUser`
- `hubGrant`
- `hubRevoke`
- `hubListGrants`

Región: **us-central1** (ver `HubApiClient`).

CORS: callables gen2 con `invoker: "public"` y `cors: true`; la autorización real es el
token Firebase + claim `hubAdmin` dentro de cada función.

## Secrets (nunca en el repo)

```powershell
cd D:\plataforma_admin

Get-Content D:\ruta\sa-cotiapp.json -Raw | firebase functions:secrets:set SA_COTIAPP_JSON --project plataforma-admin-jb --data-file -
Get-Content D:\ruta\sa-cvmaker.json -Raw | firebase functions:secrets:set SA_CVMAKER_JSON --project plataforma-admin-jb --data-file -
"TU_SECRETO_FUERTE" | firebase functions:secrets:set HUB_ADMIN_BOOTSTRAP_SECRET --project plataforma-admin-jb --data-file -
```

## Desplegar Functions y rules

```powershell
cd D:\plataforma_admin\functions
npm install
npm run build
cd ..
firebase deploy --only functions,firestore:rules --project plataforma-admin-jb
```

## HTTPS y dominio

- Las Functions ya usan HTTPS de Google (`cloudfunctions.net` / Cloud Run gen2).
- Auth: `plataforma-admin-jb.firebaseapp.com`.
- Opcional — Firebase Hosting para la web:

```powershell
# Tras añadir hosting en firebase.json (si aún no está):
flutter build web
firebase deploy --only hosting --project plataforma-admin-jb
```

Dominio personalizado: Firebase Hosting → Add custom domain (acción manual en Console).

## Variables / configuración por entorno

| Entorno | Cómo se configura |
|---------|-------------------|
| Producción móvil/web | `DefaultFirebaseOptions` + proyecto `plataforma-admin-jb` |
| Debug Android | `google-services.json` + SHA debug |
| Release Android | Keystore propio + SHA release en Firebase |
| iOS | `GoogleService-Info.plist` + Team Apple |

No hay URL de API distinta por entorno: el endpoint lo resuelve el SDK de Firebase
según `projectId` + región `us-central1`.

## Base de datos y backups

- Firestore: backups gestionados en Console (Backup schedules) o export a GCS.
- No migrar datos de producción sin autorización explícita.
- Índices: `firestore.indexes.json`.

## Seguridad de despliegue

1. Claim `hubAdmin` solo en Auth del hub.
2. Colecciones `hubAdmins`, `hubAuditLogs`, `productRegistry`: sin acceso cliente.
3. Secrets en Secret Manager (Functions), no en `.env` del cliente.
4. Apps móviles sin cleartext HTTP (`usesCleartextTraffic=false`).
5. Limitar cuentas `hubAdmin` (ideal 1–2).
6. Rotar service accounts si se filtran.

## Comprobaciones post-despliegue

1. Login web: `flutter run -d chrome` → email/password hubAdmin.
2. Login Android: `flutter run -d <device>` → mismos credenciales.
3. Callable `hubListProducts` lista CotiApp / CV Maker.
4. Grant/revoke de cortesía en un usuario de prueba del producto.
5. Usuario sin claim ve pantalla “Sin permiso”.

## Acciones que debes completar tú

- [ ] Verificar secrets `SA_*` y `HUB_ADMIN_BOOTSTRAP_SECRET` en el proyecto.
- [ ] Confirmar primer `hubAdmin` (o ejecutar bootstrap).
- [ ] (Opcional) Activar Firebase Hosting + dominio.
- [ ] (Opcional) Programar backups de Firestore.
- [ ] Cuenta Google Play / Apple Developer para publicación de tiendas.
- [ ] Keystore de release Android y perfiles de firma iOS.

## Lo que NO está hecho automáticamente

- Publicación en Google Play o App Store.
- Migración de datos entre proyectos.
- Despliegue de Hosting (salvo que lo ejecutes con los comandos de arriba).
