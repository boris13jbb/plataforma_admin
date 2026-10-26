import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// True cuando el fallo parece de red/servicio y no de autorización ni lógica.
///
/// Usado para degradar de forma segura a registry local en listados, sin
/// ocultar `permission-denied` / `unauthenticated` u otros errores reales.
bool isHubTransientConnectivityError(Object error) {
  if (error is FirebaseAuthException) {
    return error.code == 'network-request-failed';
  }
  if (error is FirebaseFunctionsException) {
    return error.code == 'unavailable' ||
        error.code == 'deadline-exceeded' ||
        error.code == 'resource-exhausted';
  }
  final lower = error.toString().toLowerCase();
  return lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('failed host lookup') ||
      lower.contains('timeout');
}

/// Mensajes legibles para fallos de red / Firebase en móvil y web.
String hubFriendlyError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'network-request-failed':
        return 'Sin conexión. Comprueba Wi‑Fi o datos móviles e inténtalo de nuevo.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-not-found':
        return 'Email o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos e inténtalo otra vez.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      default:
        return error.message ?? error.code;
    }
  }

  if (error is FirebaseFunctionsException) {
    switch (error.code) {
      case 'unavailable':
      case 'deadline-exceeded':
        return 'No hay conexión con el servidor. '
            'Verifica Internet (Wi‑Fi o datos) y vuelve a intentar.';
      case 'unauthenticated':
      case 'permission-denied':
        return 'No autorizado. Cierra sesión y vuelve a entrar, o pide rol hubAdmin.';
      case 'failed-precondition':
        return error.message ??
            'La operación no está disponible en el estado actual del hub.';
      default:
        return error.message ?? error.code;
    }
  }

  final text = error.toString();
  final lower = text.toLowerCase();
  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('failed host lookup') ||
      lower.contains('unavailable') ||
      lower.contains('deadline-exceeded') ||
      lower.contains('timeout')) {
    return 'No hay conexión con el servidor. '
        'Verifica Internet (Wi‑Fi o datos) y vuelve a intentar.';
  }
  if (lower.contains('permission-denied') ||
      lower.contains('unauthenticated')) {
    return 'No autorizado. Cierra sesión y vuelve a entrar, o pide rol hubAdmin.';
  }
  if (kDebugMode) return text;
  return 'Ocurrió un error al contactar el hub. Inténtalo de nuevo.';
}
