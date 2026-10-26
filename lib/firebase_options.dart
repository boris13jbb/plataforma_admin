// File generated for hub project plataforma-admin-jb (FlutterFire / Firebase Console).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones del proyecto hub `plataforma-admin-jb` por plataforma.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no estánados para '
          '${defaultTargetPlatform.name}. Usa FlutterFire configure.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC4nVSSKD0OMYMAvYwf0WknKST-eOH42KA',
    appId: '1:23946566134:android:37d4e4872428d9c24c0fd7',
    messagingSenderId: '23946566134',
    projectId: 'plataforma-admin-jb',
    storageBucket: 'plataforma-admin-jb.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCBSTh-vcXOAzhg5_gJPDjF_i3x-iInQZQ',
    appId: '1:23946566134:ios:81c7ae2c4b0b32544c0fd7',
    messagingSenderId: '23946566134',
    projectId: 'plataforma-admin-jb',
    storageBucket: 'plataforma-admin-jb.firebasestorage.app',
    iosBundleId: 'com.plataformaadmin.plataformaAdmin',
  );
}
