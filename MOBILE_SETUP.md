# Configuración móvil — Plataforma Admin

Aplicación Flutter multiplataforma (Android, iOS, Web, Windows) conectada al backend
Firebase del hub `plataforma-admin-jb`.

## Arquitectura móvil (decisión)

| Alternativa | Evaluación |
|-------------|------------|
| Capacitor | No aplica: el frontend ya es Flutter, no un SPA web a encapsular. |
| React Native | Reescritura completa; alto costo y duplicación. |
| **Flutter nativo (elegido)** | Mismo código Dart para Android, iOS y Web. Backend ya remoto (Cloud Functions). |

**Identificadores**

| Plataforma | ID |
|------------|-----|
| Android `applicationId` | `com.plataformaadmin.plataforma_admin` |
| iOS `bundleId` | `com.plataformaadmin.plataformaAdmin` |
| Nombre visible | Plataforma Admin |
| Firebase project | `plataforma-admin-jb` |

## Requisitos

- Flutter 3.44+ / Dart 3.12+
- Android Studio + SDK (para APK/dispositivo)
- macOS + Xcode (solo para compilar iOS)
- Cuenta Firebase con acceso a `plataforma-admin-jb`
- Usuario Auth con claim `hubAdmin` (ver `SAAS_HUB.md`)

## Instalación de dependencias

```powershell
cd D:\plataforma_admin
flutter pub get
cd functions
npm install
cd ..
```

## Firebase en móvil

Ya estánados en el repo:

- `lib/firebase_options.dart` — opciones Web / Android / iOS
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Plugin Gradle `com.google.gms.google-services`
- SHA-1 del keystore **debug** registrado en Firebase

Si regeneras las apps en Firebase Console:

```powershell
$env:Path = "$env:LOCALAPPDATA\Pub\Cache\bin;$env:Path"
dart pub global activate flutterfire_cli
flutterfire configure --project=plataforma-admin-jb --platforms=android,ios,web --yes --out=lib/firebase_options.dart
```

Para un keystore de **release**, añade su SHA-1/SHA-256 en Firebase Console → Project settings → Android app.

## Ejecutar en Android (dispositivo físico o emulador)

1. Activa depuración USB / empareja por Wi‑Fi ADB.
2. Comprueba el dispositivo:

```powershell
flutter devices
```

3. Instala y ejecuta:

```powershell
flutter run -d android
# o el id concreto, por ejemplo:
# flutter run -d 1b520528
```

4. APK de depuración:

```powershell
flutter build apk --debug
# salida: build\app\outputs\flutter-apk\app-debug.apk
```

5. APK release (firma debug por defecto; cambia keystore antes de Play Store):

```powershell
flutter build apk --release
```

### Licencias Android

Si `flutter doctor` indica licencias pendientes:

```powershell
flutter doctor --android-licenses
```

## Ejecutar en iOS (requiere macOS)

En este entorno Windows **no** se puede generar un binario iOS. En un Mac:

```bash
cd /ruta/plataforma_admin
flutter pub get
cd ios && pod install && cd ..
flutter run -d ios
# o abrir:
open ios/Runner.xcworkspace
```

Firma: Xcode → Signing & Capabilities → Team de Apple Developer.

## Ejecutar en Web (computadoras / navegador móvil)

```powershell
flutter run -d chrome
# o build estático:
flutter build web
```

Hosting opcional: Firebase Hosting (ver `DEPLOYMENT.md`).

## Conectividad: Wi‑Fi local vs Internet

El backend **no** corre en tu PC: son Cloud Functions en `us-central1`.

| Escenario | Qué usa la app |
|-----------|----------------|
| Celular en Wi‑Fi local | HTTPS → Firebase (Internet) |
| Celular con datos móviles | HTTPS → Firebase (Internet) |
| Emulador Android | HTTPS → Firebase |
| Navegador Chrome en PC | HTTPS → Firebase |

No hace falta apuntar a `localhost` ni a la IP LAN de tu PC para la API del hub.

Si en el futuro usas **emuladores Firebase locales**:

```powershell
# Solo desarrollo con emulators (opcional)
firebase emulators:start --project plataforma-admin-jb
```

Y en Dart (solo debug) conectar Auth/Functions al host de la red. No está activado por defecto a propósito: la app de producción/pruebas usa el backend remoto real.

### Cómo obtener tu IP LAN (solo si sirves algo local)

```powershell
ipconfig
# Busca "Adaptador de LAN inalámbrica" → IPv4
```

Úsala solo para assets locales o un proxy propio; **no** sustituye a Cloud Functions.

## Permisos nativos

- Android: `INTERNET` (manifest). Sin cámara, ubicación ni almacenamiento extra.
- iOS: sin permisos sensibles adicionales en `Info.plist` (solo Auth + Functions).

## Solución de problemas

| Síntoma | Acción |
|---------|--------|
| `network-request-failed` | Revisar Internet del teléfono; no es un fallo de “IP local”. |
| Sin `hubAdmin` | Bootstrap con secreto o pedir claim (SAAS_HUB.md). |
| Gradle / google-services | Confirmar `google-services.json` en `android/app/`. |
| iOS no compila en Windows | Usar Mac con Xcode. |
| SHA mismatch en release | Registrar SHA del keystore de release en Firebase. |
