import 'package:flutter_test/flutter_test.dart';
import 'package:plataforma_admin/products/product_registry.dart';

void main() {
  test('smoke: registry del hub está disponible', () {
    expect(ProductRegistry.builtIn, isNotEmpty);
    expect(ProductRegistry.byId('cotiapp'), isNotNull);
  });
}
