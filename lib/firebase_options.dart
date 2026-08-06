// File generated for hub project plataforma-admin-jb (FlutterFire / Firebase Console).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones del proyecto hub `plataforma-admin-jb`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBunYz9MQ6iHemhegfRp8McF0qIARk608',
    appId: '1:23946566134:web:e53f2954141e23984c0fd7',
    messagingSenderId: '23946566134',
    projectId: 'plataforma-admin-jb',
    authDomain: 'plataforma-admin-jb.firebaseapp.com',
    storageBucket: 'plataforma-admin-jb.firebasestorage.app',
  );
}
