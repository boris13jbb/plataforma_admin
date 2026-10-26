# Compilación iOS — Plataforma Admin

**Bundle ID:** `com.plataformaadmin.plataformaAdmin`  
**Firebase iOS appId:** `1:23946566134:ios:81c7ae2c4b0b32544c0fd7`  
**Proyecto:** `plataforma-admin-jb`

## Estado verificado (2026-10-25, host Windows)

| Comprobación | Resultado |
|--------------|-----------|
| Entorno macOS / Xcode | **No disponible** |
| `PRODUCT_BUNDLE_IDENTIFIER` = `com.plataformaadmin.plataformaAdmin` | OK |
| `GoogleService-Info.plist` en disco (`ios/Runner/`) | OK |
| `BUNDLE_ID` del plist = bundle del proyecto | OK |
| Plist en grupo Runner + **Copy Bundle Resources** (`project.pbxproj`) | OK (integrado en esta fase) |
| `DefaultFirebaseOptions.ios` / `iosBundleId` | OK |
| `pod install` / `.ipa` / TestFlight | **Pendiente en Mac** |
| Binario iOS funcional | **No existe** — no declarado |

## Firebase iOS

Archivo nativo: `ios/Runner/GoogleService-Info.plist`  
Dart: `lib/firebase_options.dart` → `DefaultFirebaseOptions.ios`

Ambos deben permanecer alineados con el mismo `GOOGLE_APP_ID` / bundle.

## Pasos exactos en Mac

```bash
cd /ruta/plataforma_admin
flutter pub get
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

En Xcode:

1. Target **Runner** → Signing & Capabilities → Team Apple Developer.
2. Bundle Identifier = `com.plataformaadmin.plataformaAdmin`.
3. Confirmar que `GoogleService-Info.plist` aparece en Runner y en Build Phases → Copy Bundle Resources (ya referenciado en `project.pbxproj`).
4. Seleccionar iPhone físico o simulador.

```bash
flutter devices
flutter run -d <device_id>

# Distribución:
flutter build ipa
# Subir con Organizer / Transporter → TestFlight
```

## Prueba en iPhone físico (checklist)

- [ ] Login hubAdmin
- [ ] Dashboard CotiApp / CV Maker
- [ ] Lookup usuario
- [ ] Safe areas / teclado / rotación
- [ ] Sin grant/revoke a usuarios reales sin autorización

## Bloqueos

- Compilación iOS imposible en Windows.
- Cuenta Apple Developer de pago para dispositivo físico y TestFlight.
- Firma/provisioning solo configurables en Xcode con Team.

**No hay `.ipa` generado en este entorno.**
