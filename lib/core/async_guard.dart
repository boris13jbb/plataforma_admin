/// Candado de exclusión mutua para operaciones de UI asíncronas.
///
/// Evita dobles envíos (doble tap / reentrada). Las llamadas anidadas
/// bajo el mismo `runExclusive` deben invocarse directamente (sin
/// reentrar por el candado).
class AsyncGuard {
  bool _locked = false;

  bool get isLocked => _locked;

  /// Intenta adquirir el candado. Devuelve false si ya hay una op en curso.
  bool tryLock() {
    if (_locked) return false;
    _locked = true;
    return true;
  }

  void unlock() {
    _locked = false;
  }

  /// Ejecuta [action] bajo exclusión. Si ya hay lock, no corre y retorna null.
  Future<T?> runExclusive<T>(Future<T> Function() action) async {
    if (!tryLock()) return null;
    try {
      return await action();
    } finally {
      unlock();
    }
  }
}
