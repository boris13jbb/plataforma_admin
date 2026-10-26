import 'package:flutter/material.dart';
import '../../core/api_errors.dart';
import '../../core/async_guard.dart';
import '../../core/responsive.dart';
import '../../products/product_models.dart';
import '../../services/hub_api_client.dart';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key, required this.product});

  final HubProduct product;

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final _api = HubApiClient();
  final _ops = AsyncGuard();
  final _search = TextEditingController();
  final _reason = TextEditingController(text: 'Acceso cortesía / piloto (hub)');
  late String _plan;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _metrics;
  Map<String, dynamic>? _user;
  List<dynamic> _grants = [];

  HubProduct get product => widget.product;

  bool get _busy => _ops.isLocked || _loading;

  @override
  void initState() {
    super.initState();
    _plan = product.grantPlans.first;
    _runUserOp(_refreshBody);
  }

  @override
  void dispose() {
    _search.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _runUserOp(Future<void> Function() body) async {
    final ran = await _ops.runExclusive(() async {
      if (!mounted) return;
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        await body();
      } catch (e) {
        if (mounted) setState(() => _error = hubFriendlyError(e));
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    });
    // ran == null ⇒ operación descartada por candado (doble tap / reentrada)
    if (ran == null && mounted && !_loading) {
      // no-op silencioso: el usuario ya tiene una op en curso
    }
  }

  Future<void> _refreshBody() async {
    final results = await Future.wait([
      if (product.has(ProductCapability.metrics))
        _api.metrics(product.id)
      else
        Future.value(<String, dynamic>{}),
      if (product.has(ProductCapability.listGrants))
        _api.listGrants(productId: product.id)
      else
        Future.value(<String, dynamic>{'grants': []}),
    ]);
    if (!mounted) return;
    setState(() {
      _metrics = results[0];
      _grants = (results[1]['grants'] as List?) ?? [];
    });
  }

  Future<void> _lookupBody() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    final isEmail = q.contains('@');
    final res = await _api.lookupUser(
      productId: product.id,
      email: isEmail ? q : null,
      uid: isEmail ? null : q,
    );
    if (!mounted) return;
    setState(() => _user = Map<String, dynamic>.from(res['user'] as Map));
  }

  Future<void> _refresh() => _runUserOp(_refreshBody);

  Future<void> _lookup() => _runUserOp(() async {
        setState(() => _user = null);
        await _lookupBody();
      });

  Future<void> _grant() => _runUserOp(() async {
        final uid = _user?['uid'] as String?;
        final email = _user?['email'] as String?;
        if (uid == null && email == null) return;
        if (_reason.text.trim().isEmpty) {
          setState(() => _error = 'El motivo es obligatorio.');
          return;
        }
        await _api.grant(
          productId: product.id,
          plan: _plan,
          reason: _reason.text.trim(),
          uid: uid,
          email: email,
        );
        // Anidado bajo el mismo candado: no reentrar por _runUserOp.
        await _lookupBody();
        await _refreshBody();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso de cortesía otorgado')),
        );
      });

  Future<void> _revoke() => _runUserOp(() async {
        final uid = _user?['uid'] as String?;
        final email = _user?['email'] as String?;
        if (uid == null && email == null) return;
        final ent = _user?['entitlements'] as Map?;
        final grantId = ent?['grantId'] as String?;
        await _api.revoke(
          productId: product.id,
          uid: uid,
          email: email,
          grantId: grantId,
          reason: _reason.text.trim(),
        );
        await _lookupBody();
        await _refreshBody();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso revocado')),
        );
      });

  @override
  Widget build(BuildContext context) {
    final ent = _user?['entitlements'] as Map?;
    final bottomInset = context.hubViewInsets.bottom;
    final narrow = context.isPhone;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(product.displayName),
        actions: [
          IconButton(
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.pageHorizontalPadding,
            16,
            context.pageHorizontalPadding,
            16 + bottomInset,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Text(
              product.firebaseProjectId,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (_metrics != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _metrics!.entries
                    .where((e) => e.value is num || e.value is String)
                    .take(8)
                    .map(
                      (e) => Chip(
                        label: Text('${e.key}: ${e.value}'),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 24),
            Text(
              'Buscar cliente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (narrow) ...[
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Email o UID',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (_) => _busy ? null : _lookup(),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _busy ? null : _lookup,
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Email o UID',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _busy ? null : _lookup(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _lookup,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
            if (_user != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user!['email']?.toString() ?? 'Sin email',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      SelectableText('UID: ${_user!['uid']}'),
                      Text('Nombre: ${_user!['displayName'] ?? '—'}'),
                      Text(
                        'Plan: ${ent?['plan'] ?? '—'} · '
                        '${ent?['subscriptionStatus'] ?? '—'} · '
                        'source=${ent?['source'] ?? '—'}',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _plan,
                        decoration: const InputDecoration(
                          labelText: 'Plan a otorgar',
                        ),
                        items: product.grantPlans
                            .map(
                              (p) =>
                                  DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: _busy
                            ? null
                            : (v) => setState(
                                  () => _plan = v ?? product.grantPlans.first,
                                ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reason,
                        enabled: !_busy,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Motivo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (product.has(ProductCapability.grant))
                            FilledButton.icon(
                              onPressed: _busy ? null : _grant,
                              icon: const Icon(Icons.card_giftcard),
                              label: const Text('Dar acceso gratis'),
                            ),
                          if (product.has(ProductCapability.revoke))
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _revoke,
                              icon: const Icon(Icons.block),
                              label: const Text('Revocar'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Grants / auditoría reciente',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_busy && _grants.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_grants.isEmpty)
              const Text('Sin registros todavía')
            else
              ..._grants.take(30).map((g) {
                final m = Map<String, dynamic>.from(g as Map);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      '${m['targetUid'] ?? m['uid'] ?? m['action'] ?? ''} '
                      '· ${m['plan'] ?? m['action'] ?? ''}',
                    ),
                    subtitle: Text(
                      '${m['reason'] ?? m['note'] ?? ''}\n'
                      '${m['createdAt'] ?? ''}'
                      '${m['revokedAt'] != null ? ' · REVOCADO' : ''}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
