import 'product_models.dart';

/// Registro local de productos (espejo del backend).
/// Para una app nueva: añade una entrada aquí y el connector + secret en Functions.
class ProductRegistry {
  ProductRegistry._();

  static const List<HubProduct> builtIn = [
    HubProduct(
      id: 'cotiapp',
      displayName: 'CotiApp',
      firebaseProjectId: 'cotiapp-saas-jb',
      capabilities: [
        ProductCapability.metrics,
        ProductCapability.lookupUser,
        ProductCapability.grant,
        ProductCapability.revoke,
        ProductCapability.listGrants,
      ],
      grantPlans: ['pro', 'business'],
      description: 'Cotizaciones SaaS — grants Pro/Business de cortesía',
    ),
    HubProduct(
      id: 'cvmaker',
      displayName: 'CV Maker',
      firebaseProjectId: 'cvmaker-saas-jb',
      capabilities: [
        ProductCapability.metrics,
        ProductCapability.lookupUser,
        ProductCapability.grant,
        ProductCapability.revoke,
        ProductCapability.listGrants,
      ],
      grantPlans: ['pro'],
      description: 'CVs SaaS — grants Pro de cortesía',
    ),
  ];

  static HubProduct? byId(String id) {
    try {
      return builtIn.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
