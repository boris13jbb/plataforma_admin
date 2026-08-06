import 'package:flutter_test/flutter_test.dart';
import 'package:plataforma_admin/products/product_registry.dart';

void main() {
  test('registry incluye cotiapp y cvmaker', () {
    expect(ProductRegistry.builtIn.length, greaterThanOrEqualTo(2));
    expect(ProductRegistry.byId('cotiapp')?.grantPlans, contains('business'));
    expect(ProductRegistry.byId('cvmaker')?.grantPlans, equals(['pro']));
  });
}
