import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Provides the correct [FirebaseOptions] for the current runtime platform.
///
/// Usage:
/// ```dart
/// import 'firebase_options.dart';
///
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  // ---------------------------------------------------------------------------
  // Platform configurations
  // ---------------------------------------------------------------------------

  /// Firebase options for Android builds.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-i3m8tWc91L3hzah7_vnD1_S1i64DKG8',
    appId: '1:391973598755:android:c6f9cb7212f42c115aa396',
    messagingSenderId: '391973598755',
    projectId: 'pacman-school',
    databaseURL:
        'https://pacman-school-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pacman-school.firebasestorage.app',
  );

  /// Firebase options for iOS builds.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvNmv5jLcj-cn0QncdPhnxhHQgJgOH0Vs',
    appId: '1:391973598755:ios:b0e1a292883162275aa396',
    messagingSenderId: '391973598755',
    projectId: 'pacman-school',
    databaseURL:
        'https://pacman-school-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pacman-school.firebasestorage.app',
    iosBundleId: 'com.example.pacmanApplication',
  );

  /// Firebase options for macOS builds.
  ///
  /// Shares the same credentials as [ios] because macOS and iOS targets use
  /// the same Apple bundle.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvNmv5jLcj-cn0QncdPhnxhHQgJgOH0Vs',
    appId: '1:391973598755:ios:b0e1a292883162275aa396',
    messagingSenderId: '391973598755',
    projectId: 'pacman-school',
    databaseURL:
        'https://pacman-school-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pacman-school.firebasestorage.app',
    iosBundleId: 'com.example.pacmanApplication',
  );

  /// Firebase options for Web builds.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDc6ve6jeS5cNAiyZTx6M_m6eyDkTqTjfI',
    appId: '1:391973598755:web:e9cc61a4040b8b0a5aa396',
    messagingSenderId: '391973598755',
    projectId: 'pacman-school',
    authDomain: 'pacman-school.firebaseapp.com',
    databaseURL:
        'https://pacman-school-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pacman-school.firebasestorage.app',
  );

  /// Firebase options for Windows builds.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDc6ve6jeS5cNAiyZTx6M_m6eyDkTqTjfI',
    appId: '1:391973598755:web:a57414f7160afb765aa396',
    messagingSenderId: '391973598755',
    projectId: 'pacman-school',
    authDomain: 'pacman-school.firebaseapp.com',
    databaseURL:
        'https://pacman-school-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pacman-school.firebasestorage.app',
  );

  // ---------------------------------------------------------------------------
  // Platform resolver
  // ---------------------------------------------------------------------------

  /// Returns the [FirebaseOptions] that match the current runtime platform.
  ///
  /// Throws an [UnsupportedError] for Linux or any unrecognized platform,
  /// because FlutterFire has not been configured for those targets.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux. '
          'Re-run the FlutterFire CLI to add Linux support.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}