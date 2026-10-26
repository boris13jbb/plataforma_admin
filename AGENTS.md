## Learned User Preferences

- Responder siempre en español, con tono claro y profesional.
- Mantener el stack Flutter + Firebase; no migrar a Capacitor, React Native u otra arquitectura móvil alternativa salvo petición explícita.
- Continuar desde el estado real del repositorio y conservar cambios locales existentes; no reconstruir la arquitectura desde cero.
- Cuando pida reglas o políticas transversales (p. ej. versionado Git/GitHub), configurarlas como reglas globales de Cursor reutilizables en todos los proyectos, no solo en este repo.
- Entregar soluciones listas para uso real en dispositivos físicos (Android/iOS) y web, con acceso local y remoto, no maquetas ni simulaciones.
- No inventar keystores, contraseñas ni secretos; no ejecutar revoke/grant reales, deploy, commit, push ni publicación en tiendas sin autorización explícita e independiente.

## Learned Workspace Facts

- Este repo es el hub SaaS Super Admin Flutter (`plataforma_admin`) para productos como CotiApp y CV Maker; remoto GitHub: `boris13jbb/plataforma_admin`.
- El proyecto Firebase del hub es `plataforma-admin-jb` (Auth, Firestore, Cloud Functions en `us-central1`); no confundirlo con productos legacy como `cotiapp-saas-jb`.
- El bootstrap del hub usa el secreto `HUB_ADMIN_BOOTSTRAP_SECRET`; CotiApp legacy usa otro (`PLATFORM_ADMIN_BOOTSTRAP_SECRET`) — no intercambiarlos.
- Los service accounts de productos se inyectan en Functions del hub vía secrets (`SA_COTIAPP_JSON`, `SA_CVMAKER_JSON`); el plan Blaze es requerido para Functions y secrets.
- Package Android: `com.plataformaadmin.plataforma_admin`; bundle iOS: `com.plataformaadmin.plataformaAdmin`; opciones en `lib/firebase_options.dart` y nativos FlutterFire.
- Autorización admin del hub: custom claim `hubAdmin` (estricto) vía `assertHubAdmin` en Cloud Functions; no confiar solo en la UI.
- Firma Android release: `key.properties` y keystore fuera del repo (p. ej. bajo `D:\secure\`, alias `plataforma_admin_release`); sin `key.properties` el debug sigue compilando; ambos ignorados por Git.
- Huellas SHA del certificado de release registradas en Firebase Console para la app Android del hub.
- Documentación operativa del hub: `SAAS_HUB.md`, `MOBILE_SETUP.md`, `MOBILE_TESTING.md`, `DEPLOYMENT.md`, `IOS_BUILD.md`, `ANDROID_RELEASE.md`, `PRODUCTION_CHECKLIST.md`, `REVOKE_CONTROLLED.md`.
