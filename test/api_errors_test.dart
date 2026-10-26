import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plataforma_admin/core/api_errors.dart';

void main() {
  group('isHubTransientConnectivityError', () {
    test('true para unavailable / deadline / resource-exhausted', () {
      expect(
        isHubTransientConnectivityError(
          FirebaseFunctionsException(code: 'unavailable', message: 'x'),
        ),
        isTrue,
      );
      expect(
        isHubTransientConnectivityError(
          FirebaseFunctionsException(code: 'deadline-exceeded', message: 'x'),
        ),
        isTrue,
      );
      expect(
        isHubTransientConnectivityError(
          FirebaseFunctionsException(code: 'resource-exhausted', message: 'x'),
        ),
        isTrue,
      );
    });

    test('false para permission-denied y unauthenticated', () {
      expect(
        isHubTransientConnectivityError(
          FirebaseFunctionsException(code: 'permission-denied', message: 'x'),
        ),
        isFalse,
      );
      expect(
        isHubTransientConnectivityError(
          FirebaseFunctionsException(code: 'unauthenticated', message: 'x'),
        ),
        isFalse,
      );
    });

    test('true para mensajes de red genéricos', () {
      expect(
        isHubTransientConnectivityError(Exception('SocketException: failed')),
        isTrue,
      );
      expect(
        isHubTransientConnectivityError(Exception('Failed host lookup')),
        isTrue,
      );
    });
  });

  group('hubFriendlyError', () {
    test('mapea permission-denied a mensaje de no autorizado', () {
      final msg = hubFriendlyError(
        FirebaseFunctionsException(code: 'permission-denied', message: 'no'),
      );
      expect(msg.toLowerCase(), contains('autorizado'));
    });
  });
}
