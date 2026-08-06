import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/login/login_screen.dart';
import 'hub/hub_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    firebaseError = e;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => HubSession(),
      child: PlataformaAdminApp(firebaseError: firebaseError),
    ),
  );
}

class PlataformaAdminApp extends StatelessWidget {
  const PlataformaAdminApp({super.key, this.firebaseError});

  final Object? firebaseError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plataforma Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: firebaseError != null
          ? _FirebaseSetupScreen(error: firebaseError!)
          : const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<HubSession>();
    if (session.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!session.isAuthenticated) {
      return const LoginScreen();
    }
    if (!session.isHubAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sin permiso'),
          actions: [
            IconButton(
              onPressed: () => session.refreshClaims(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Reintentar claims',
            ),
            IconButton(
              onPressed: () => session.signOut(),
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.error ?? 'Se requiere claim hubAdmin.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Si eres el primer administrador, vuelve al login y usa '
                '“Activar primer hubAdmin” con el secreto HUB_ADMIN_BOOTSTRAP_SECRET.',
              ),
            ],
          ),
        ),
      );
    }
    return const DashboardScreen();
  }
}

class _FirebaseSetupScreen extends StatelessWidget {
  const _FirebaseSetupScreen({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configura Firebase del hub',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea el proyecto plataforma-admin-jb y ejecuta FlutterFire. '
              'Detalle en SAAS_HUB.md.\n\nError: $error',
            ),
          ],
        ),
      ),
    );
  }
}
