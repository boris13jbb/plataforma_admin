import 'package:flutter/material.dart';
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
  final _search = TextEditingController();
  final _reason = TextEditingController(text: 'Acceso cortesía / piloto (hub)');
  late String _plan;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _metrics;
  Map<String, dynamic>? _user;
  List<dynamic> _grants = [];

  HubProduct get product => widget.product;

  @override
  void initState() {
    super.initState();
    _plan = product.grantPlans.first;
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
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
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _lookup() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _user = null;
    });
    try {
      final isEmail = q.contains('@');
      final res = await _api.lookupUser(
        productId: product.id,
        email: isEmail ? q : null,
        uid: isEmail ? null : q,
      );
      if (!mounted) return;
      setState(() => _user = Map<String, dynamic>.from(res['user'] as Map));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _grant() async {
    final uid = _user?['uid'] as String?;
    final email = _user?['email'] as String?;
    if (uid == null && email == null) return;
    setState(() => _loading = true);
    try {
      await _api.grant(
        productId: product.id,
        plan: _plan,
        reason: _reason.text.trim(),
        uid: uid,
        email: email,
      );
      await _lookup();
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso de cortesía otorgado')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _revoke() async {
    final uid = _user?['uid'] as String?;
    final email = _user?['email'] as String?;
    if (uid == null && email == null) return;
    final ent = _user?['entitlements'] as Map?;
    final grantId = ent?['grantId'] as String?;
    setState(() => _loading = true);
    try {
      await _api.revoke(
        productId: product.id,
        uid: uid,
        email: email,
        grantId: grantId,
        reason: _reason.text.trim(),
      );
      await _lookup();
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso revocado')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ent = _user?['entitlements'] as Map?;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.displayName),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          Text('Buscar cliente', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Email o UID',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _lookup(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _lookup,
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
                    Text('UID: ${_user!['uid']}'),
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
                        border: OutlineInputBorder(),
                      ),
                      items: product.grantPlans
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _plan = v ?? product.grantPlans.first),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reason,
                      decoration: const InputDecoration(
                        labelText: 'Motivo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (product.has(ProductCapability.grant))
                          FilledButton.icon(
                            onPressed: _loading ? null : _grant,
                            icon: const Icon(Icons.card_giftcard),
                            label: const Text('Dar acceso gratis'),
                          ),
                        if (product.has(ProductCapability.revoke))
                          OutlinedButton.icon(
                            onPressed: _loading ? null : _revoke,
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
          if (_loading && _grants.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (_grants.isEmpty)
            const Text('Sin registros todavía')
          else
            ..._grants.take(30).map((g) {
              final m = Map<String, dynamic>.from(g as Map);
              return ListTile(
                dense: true,
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
              );
            }),
        ],
      ),
    );
  }
}
