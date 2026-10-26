# Android Release — Plataforma Admin

**applicationId:** `com.plataformaadmin.plataforma_admin`  
**Firebase Android appId:** `1:23946566134:android:37d4e4872428d9c24c0fd7`  
**Proyecto:** `plataforma-admin-jb`

## Estado verificado (2026-10-25 — auditoría producción)

| Comprobación | Resultado |
|--------------|-----------|
| Firma release opcional (`key.properties` ausente → debug) | OK en `android/app/build.gradle.kts` |
| `android/key.properties` local presente, **ignorado por Git** | OK |
| Keystore fuera del repo (`D:\secure\…`) | OK |
| `*.jks` / `*.keystore` ignorados | OK |
| `key.properties.example` versionado (sin secretos) | OK |
| `google-services.json` package = applicationId | OK |
| `DefaultFirebaseOptions.android` projectId hub | OK |
| Firebase Console/API: SHA-1 release + SHA-256 + SHA-1 debug | OK (verificado remotamente) |
| AAB / APK firmados con certificado release esperado | **OK** |
| Instalación física APK release | **OK** (firma instalada = release) |
| UI bootstrap en release | **Oculta** (`showHubBootstrapUi` / opción B); callable backend intacta |
| Publicación Play Store | **No realizada** |

### Artefacto verificado

- Ruta: `D:\plataforma_admin\build\app\outputs\bundle\release\app-release.aab`
- Tamaño: ~48.4 MB (50 785 940 bytes)
- `jarsigner -verify` → **jar verified**
- Certificado del AAB (no es debug): SHA-1 `1A:80:68:C0:…:39:E3` · SHA-256 `4D:F5:A3:49:…:F2:FB`
- Debug SHA-1 conocido distinto: `FA:BA:45:3F:…:B2:51`
- **Firebase SHA:** release SHA-1 + SHA-256 **registradas y verificadas** en app `com.plataformaadmin.plataforma_admin` (debug SHA conservada). `google-services.json` actualizado con oauth_client por huella.

## 1. Crear y proteger el keystore (paso manual)

Ejecutar **fuera del repo**, en una ruta segura (ej. `D:\secure\`):

```powershell
# No ejecutar dentro de D:\plataforma_admin
keytool -genkey -v `
  -keystore D:\secure\plataforma-admin-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias plataforma_admin_release
```

Almacenar en gestor de secretos (no en git, no en chat):
- ruta del `.jks`
- alias `plataforma_admin_release`
- storePassword / keyPassword

## 2. Activar firma release (local)

```powershell
copy D:\plataforma_admin\android\key.properties.example D:\plataforma_admin\android\key.properties
# Editar key.properties con rutas/passwords reales (archivo ignorado por git)
```

Contenido esperado de `android/key.properties` (valores reales solo en local):

```properties
storePassword=***
keyPassword=***
keyAlias=plataforma_admin_release
storeFile=D:/secure/plataforma-admin-release.jks
```

Gradle (`rootProject.file("key.properties")`) lee `android/key.properties`.  
Si el archivo **no** existe, `buildTypes.release` usa firma **debug** (válido para pruebas; no para Play).

## 3. SHA-1 / SHA-256 → Firebase

Con el keystore de release:

```powershell
keytool -list -v `
  -keystore D:\secure\plataforma-admin-release.jks `
  -alias plataforma_admin_release
```

1. Copia SHA-1 y SHA-256 (no las subas a git).
2. Firebase Console → Project settings → app Android `com.plataformaadmin.plataforma_admin` → Add fingerprint.
3. Si Firebase pide actualizar config, descarga `google-services.json` y reemplaza `android/app/google-services.json` (solo ese archivo de cliente).

SHA **debug** ya puede estar registrado; el de **release** es obligatorio para Auth/APIs que validan firma en producción.

## 4. Compilar AAB / APK release

```powershell
cd D:\plataforma_admin
flutter pub get

# Solo cuando exista key.properties + .jks válidos:
flutter build appbundle --release
# → build\app\outputs\bundle\release\app-release.aab

flutter build apk --release
# → build\app\outputs\flutter-apk\app-release.apk
```

Verificar firma del AAB (tras generarlo):

```powershell
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
# o con apksigner / bundletool según toolchain instalado
```

**En esta máquina:** no se generó AAB de producción porque no hay keystore (correcto: no se inventaron credenciales).

## 5. Probar build firmado (cuando exista)

1. Instalar vía `bundletool` o track **interno** Play (sin producción).
2. Login hubAdmin → métricas → lookup.
3. Confirmar package `com.plataformaadmin.plataforma_admin`.
4. No grant/revoke a usuarios reales sin autorización.

## 6. Debug sin key.properties

```powershell
flutter build apk --debug
```

Debe seguir funcionando con la firma debug; no requiere `key.properties`.

## 7. Play Store

Requiere cuenta Google Play + AAB firmado. **No publicado desde este repo.**

Referencia Flutter: https://docs.flutter.dev/deployment/android#signing-the-app
