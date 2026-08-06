/// Capacidades que un producto puede exponer al hub.
enum ProductCapability {
  metrics,
  lookupUser,
  grant,
  revoke,
  listGrants,
}

/// Definición de un producto administrable (extensible a apps futuras).
class HubProduct {
  const HubProduct({
    required this.id,
    required this.displayName,
    required this.firebaseProjectId,
    required this.capabilities,
    required this.grantPlans,
    required this.description,
  });

  final String id;
  final String displayName;
  final String firebaseProjectId;
  final List<ProductCapability> capabilities;
  final List<String> grantPlans;
  final String description;

  bool has(ProductCapability c) => capabilities.contains(c);

  factory HubProduct.fromMap(Map<String, dynamic> map) {
    final caps = ((map['capabilities'] as List?) ?? [])
        .map((e) => ProductCapability.values.firstWhere(
              (c) => c.name == e.toString(),
              orElse: () => ProductCapability.metrics,
            ))
        .toList();
    return HubProduct(
      id: map['id'] as String,
      displayName: map['displayName'] as String? ?? map['id'] as String,
      firebaseProjectId: map['firebaseProjectId'] as String? ?? '',
      capabilities: caps,
      grantPlans: ((map['grantPlans'] as List?) ?? ['pro'])
          .map((e) => e.toString())
          .toList(),
      description: map['description'] as String? ?? '',
    );
  }
}
