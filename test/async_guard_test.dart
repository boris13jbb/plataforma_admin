import 'package:flutter_test/flutter_test.dart';
import 'package:plataforma_admin/core/async_guard.dart';

void main() {
  test('bloquea reentrada concurrente', () async {
    final guard = AsyncGuard();
    var started = 0;
    var finished = 0;

    Future<void> slow() async {
      started++;
      await Future<void>.delayed(const Duration(milliseconds: 40));
      finished++;
    }

    final a = guard.runExclusive(slow);
    final b = guard.runExclusive(slow);
    await Future.wait([a, b]);

    expect(started, 1);
    expect(finished, 1);
    expect(guard.isLocked, isFalse);
  });

  test('libera el candado tras error', () async {
    final guard = AsyncGuard();
    await expectLater(
      () => guard.runExclusive(() async {
        throw StateError('boom');
      }),
      throwsA(isA<StateError>()),
    );
    expect(guard.isLocked, isFalse);

    var ran = false;
    final ok = await guard.runExclusive(() async {
      ran = true;
      return 1;
    });
    expect(ok, 1);
    expect(ran, isTrue);
  });

  test('segunda llamada retorna null sin ejecutar', () async {
    final guard = AsyncGuard();
    final first = guard.runExclusive(() async {
      await Future<void>.delayed(const Duration(milliseconds: 30));
      return 'a';
    });
    final second = await guard.runExclusive(() async => 'b');
    expect(second, isNull);
    expect(await first, 'a');
  });
}
