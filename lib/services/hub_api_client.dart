import 'package:cloud_functions/cloud_functions.dart';
import '../products/product_models.dart';
import '../products/product_registry.dart';

/// Cliente de callables del hub (proyecto plataforma-admin-jb).
class HubApiClient {
  HubApiClient({FirebaseFunctions? functions})
      : _fn = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _fn;

  Future<Map<String, dynamic>> _call(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    final result = await _fn.httpsCallable(name).call(data ?? {});
    final raw = result.data;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {'raw': raw};
  }

  Future<Map<String, dynamic>> bootstrap(String secret) =>
      _call('bootstrapHubAdmin', {'secret': secret});

  Future<List<HubProduct>> listProducts() async {
    try {
      final res = await _call('hubListProducts');
      final list = (res['products'] as List?) ?? [];
      return list
          .map((e) => HubProduct.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Fallback offline / pre-deploy: registry local.
      return ProductRegistry.builtIn;
    }
  }

  Future<Map<String, dynamic>> metrics(String productId) =>
      _call('hubProductMetrics', {'productId': productId});

  Future<Map<String, dynamic>> lookupUser({
    required String productId,
    String? email,
    String? uid,
  }) =>
      _call('hubLookupUser', {
        'productId': productId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
      });

  Future<Map<String, dynamic>> grant({
    required String productId,
    required String plan,
    required String reason,
    String? email,
    String? uid,
    String? expiresAt,
  }) =>
      _call('hubGrant', {
        'productId': productId,
        'plan': plan,
        'reason': reason,
        if (email != null && email.isNotEmpty) 'email': email,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
        'expiresAt': ?expiresAt,
      });

  Future<Map<String, dynamic>> revoke({
    required String productId,
    String? email,
    String? uid,
    String? grantId,
    String? reason,
  }) =>
      _call('hubRevoke', {
        'productId': productId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (uid != null && uid.isNotEmpty) 'uid': uid,
        if (grantId != null && grantId.isNotEmpty) 'grantId': grantId,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      });

  Future<Map<String, dynamic>> listGrants({
    required String productId,
    int limit = 50,
  }) =>
      _call('hubListGrants', {'productId': productId, 'limit': limit});
}
