import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../hub/hub_session.dart';
import '../../services/hub_api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _secret = TextEditingController();
  bool _busy = false;
  String? _localError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _localError = null;
    });
    await context.read<HubSession>().signIn(_email.text, _password.text);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _bootstrap() async {
    setState(() {
      _busy = true;
      _localError = null;
    });
    try {
      final session = context.read<HubSession>();
      await session.signIn(_email.text, _password.text);
      await HubApiClient().bootstrap(_secret.text.trim());
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
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
      setState(() => _localError = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<HubSession>();
    final error = _localError ?? session.error;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Plataforma Admin',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hub unificado · CotiApp · CV Maker · apps futuras',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email (proyecto hub)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _secret,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Secreto bootstrap (solo primer admin)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _signIn,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : _bootstrap,
                    child: const Text('Activar primer hubAdmin'),
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
