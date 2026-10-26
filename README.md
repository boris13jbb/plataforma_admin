# Plataforma Admin

Hub unificado de Super Admin para **CotiApp**, **CV Maker** y productos futuros.

- Auth: Firebase del hub (`plataforma-admin-jb`) + claim `hubAdmin`.
- Backend: Cloud Functions (HTTPS, `us-central1`) con Admin SDK multi-proyecto.
- Clientes: **Flutter** — Web, Android, iOS y Windows.

## Arranque rápido

```powershell
cd D:\plataforma_admin
flutter pub get

# Web
flutter run -d chrome

# Android (dispositivo/emulador)
flutter devices
flutter run -d android

# Windows escritorio
flutter run -d windows
```

iOS requiere macOS + Xcode — ver [MOBILE_SETUP.md](MOBILE_SETUP.md).

## Estructura

```
plataforma_admin/
  lib/                 # UI Flutter (web + móvil + desktop)
  android/             # Proyecto nativo Android
  ios/                 # Proyecto nativo iOS
  windows/             # Escritorio Windows
  functions/           # Cloud Functions del hub
  firebase.json
  firestore.rules
  SAAS_HUB.md          # Setup Firebase + productos
  MOBILE_SETUP.md      # Android / iOS / conectividad
  DEPLOYMENT.md        # Despliegue remoto y seguridad
  MOBILE_TESTING.md    # Casos de prueba y resultados
```

## Identificadores de app

| Plataforma | ID |
|------------|-----|
| Android | `com.plataformaadmin.plataforma_admin` |
| iOS | `com.plataformaadmin.plataformaAdmin` |

## Productos incluidos

| id | App | Planes grant |
|----|-----|--------------|
| `cotiapp` | CotiApp (`cotiapp-saas-jb`) | pro, business |
| `cvmaker` | CV Maker (`cvmaker-saas-jb`) | pro |

## Documentación

- [SAAS_HUB.md](SAAS_HUB.md) — Firebase, secrets, bootstrap, 3.er producto
- [MOBILE_SETUP.md](MOBILE_SETUP.md) — instalación y ejecución móvil
- [DEPLOYMENT.md](DEPLOYMENT.md) — despliegue HTTPS / Functions / Hosting
- [MOBILE_TESTING.md](MOBILE_TESTING.md) — pruebas y limitaciones
- [IOS_BUILD.md](IOS_BUILD.md) — pasos iOS en macOS (sin binario en Windows)
- [ANDROID_RELEASE.md](ANDROID_RELEASE.md) — keystore, SHA, AAB
- [REVOKE_CONTROLLED.md](REVOKE_CONTROLLED.md) — revoke de prueba (requiere autorización)
- [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md) — firma, tiendas y seguridad
