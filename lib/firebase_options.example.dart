// Template for lib/firebase_options.dart, which is not committed.
//
// To create the real file, copy this one to lib/firebase_options.dart and
// fill in the values from the Firebase console (Project settings → Your apps)
// or from the Firebase MCP `firebase_get_sdk_config` tool, for the
// "naira_spend (android)", "(ios)" and "(web)" apps in rova-d0a95.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
        'Firebase is set up for Android, iOS and web only. '
        'Run on an Android emulator, iOS simulator or Chrome.',
      ),
    };
  }

  static const android = FirebaseOptions(
    apiKey: '<android api key>',
    appId: '1:<project number>:android:<app id>',
    messagingSenderId: '<project number>',
    projectId: '<project id>',
    storageBucket: '<project id>.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: '<ios api key>',
    appId: '1:<project number>:ios:<app id>',
    messagingSenderId: '<project number>',
    projectId: '<project id>',
    storageBucket: '<project id>.firebasestorage.app',
    iosBundleId: 'com.example.nairaSpend',
  );

  static const web = FirebaseOptions(
    apiKey: '<web api key>',
    appId: '1:<project number>:web:<app id>',
    messagingSenderId: '<project number>',
    projectId: '<project id>',
    authDomain: '<project id>.firebaseapp.com',
    storageBucket: '<project id>.firebasestorage.app',
  );
}
