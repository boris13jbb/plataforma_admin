# Plataforma Admin

Hub unificado de Super Admin para **CotiApp**, **CV Maker** y productos futuros.

- Carpeta: `D:\plataforma_admin` (proyecto independiente; no mezcla código de los aplicativos).
- Auth: Firebase del hub (`plataforma-admin-jb`) + claim `hubAdmin`.
- Backend: Cloud Functions con Admin SDK multi-proyecto (service accounts).

## Arranque rápido (UI)

```powershell
cd D:\plataforma_admin
flutter pub get
# Tras configurar Firebase (ver SAAS_HUB.md):
flutter run -d chrome
```

## Estructura

```
plataforma_admin/
  lib/                 # Flutter Web (consola)
  functions/           # Cloud Functions del hub
  firebase.json
  firestore.rules
  SAAS_HUB.md          # Setup completo + cómo añadir un 3er producto
```

## Productos incluidos

| id | App | Planes grant |
|----|-----|--------------|
| `cotiapp` | CotiApp (`cotiapp-saas-jb`) | pro, business |
| `cvmaker` | CV Maker (`cvmaker-saas-jb`) | pro |

Los paneles legacy (`creador_cotizaciones/apps/admin_console`, `creador_cv/super_admin`) siguen existiendo; este hub es la consola unificada.

## Documentación

Ver [SAAS_HUB.md](SAAS_HUB.md) para Firebase, secrets, bootstrap y extensión a nuevas apps.
