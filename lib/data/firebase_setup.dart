import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../firebase_options.dart';

final _log = Logger('firebase');

/// Starts Firebase. With [useEmulators], Auth and Firestore talk to the local
/// Emulator Suite (`firebase emulators:start`) instead of production.
Future<void> initFirebase({required bool useEmulators}) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Offline after first load (docs/SPEC.md). On by default on mobile, off
  // by default on web.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  if (useEmulators) {
    // The Android emulator reaches the host machine at 10.0.2.2.
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    _log.info('Using emulators at $host (Auth 9099, Firestore 8080)');
  } else {
    _log.info('Using production project ${Firebase.app().options.projectId}');
  }
}
