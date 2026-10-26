import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_errors.dart';
import '../../core/responsive.dart';
import '../../hub/hub_session.dart';
import '../../services/hub_api_client.dart';
import 'bootstrap_admin_panel.dart';

/// Usuario autenticado sin claim hubAdmin.
///
/// El panel de bootstrap permanece disponible pero colapsado; el backend
/// rechaza la operación si ya existe un hubAdmin.
class NoPermissionScreen extends StatefulWidget {
  const NoPermissionScreen({super.key});

  @override
  State<NoPermissionScreen> createState() => _NoPermissionScreenState();
}

class _NoPermissionScreenState extends State<NoPermissionScreen> {
  final _secret = TextEditingController();
  bool _busy = false;
  String? _localError;

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final secret = _secret.text.trim();
    if (secret.isEmpty) {
      setState(() => _localError = 'Ingresa el secreto bootstrap.');
      return;
    }
    setState(() {
      _busy = true;
      _localError = null;
    });
    try {
      final session = context.read<HubSession>();
      await HubApiClient().bootstrap(secret);
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (!mounted) return;
      await session.refreshClaims();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'hubAdmin activado. Si no ves el panel, cierra sesión y vuelve a entrar.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _localError = hubFriendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<HubSession>();
    final error = _localError ?? session.error;
    final bottomInset = context.hubViewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Sin permiso'),
        actions: [
          IconButton(
            onPressed: _busy ? null : () => session.refreshClaims(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reintentar claims',
          ),
          IconButton(
            onPressed: _busy ? null : () => session.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.pageHorizontalPadding,
              16,
              context.pageHorizontalPadding,
              16 + bottomInset,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error ?? 'Se requiere claim hubAdmin.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Esta cuenta está autenticada pero no tiene rol administrativo. '
                    'Si no eres el operador del hub, cierra sesión.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  BootstrapAdminPanel(
                    secretController: _secret,
                    busy: _busy,
                    onActivate: _bootstrap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
