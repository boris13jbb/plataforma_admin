import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plataforma_admin/features/login/bootstrap_admin_panel.dart';

void main() {
  testWidgets('panel oculto cuando visible=false (equivalente release)', (
    tester,
  ) async {
    final secret = TextEditingController();
    addTearDown(secret.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BootstrapAdminPanel(
            secretController: secret,
            busy: false,
            onActivate: () {},
            visible: false,
          ),
        ),
      ),
    );

    expect(find.text('Primer administrador (avanzado)'), findsNothing);
    expect(find.text('Activar primer hubAdmin'), findsNothing);
    expect(find.text('Secreto bootstrap'), findsNothing);
  });

  testWidgets('panel visible cuando visible=true (debug/profile)', (
    tester,
  ) async {
    final secret = TextEditingController();
    addTearDown(secret.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BootstrapAdminPanel(
            secretController: secret,
            busy: false,
            onActivate: () {},
            visible: true,
          ),
        ),
      ),
    );

    expect(find.text('Primer administrador (avanzado)'), findsOneWidget);
    // Contenido del ExpansionTile solo tras expandir.
    await tester.tap(find.text('Primer administrador (avanzado)'));
    await tester.pumpAndSettle();
    expect(find.text('Activar primer hubAdmin'), findsOneWidget);
    expect(find.text('Secreto bootstrap'), findsOneWidget);
  });

  test('showHubBootstrapUi es false solo en release compilado', () {
    // En `flutter test` el modo no es release: la UI de bootstrap permanece
    // disponible para inicialización controlada en debug/profile.
    expect(showHubBootstrapUi, isTrue);
  });
}
