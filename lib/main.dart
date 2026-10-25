import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:marionette_logging/marionette_logging.dart';

import 'app.dart';
import 'app_logging.dart';
import 'data/firebase_setup.dart';
import 'data/repositories/firebase_auth_repository.dart';
import 'data/repositories/firestore_repositories.dart';
import 'logic/controllers/user_session.dart';
import 'ui/theme/font_licenses.dart';

/// Debug builds use the Firebase Emulator Suite unless built with
/// `--dart-define=USE_FIREBASE_EMULATORS=false`.
const _useEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: kDebugMode,
);

Future<void> main() async {
  // Marionette lets AI agents drive the app; debug builds only.
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(
      MarionetteConfiguration(logCollector: LoggingLogCollector()),
    );
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  setUpLogging();
  registerFontLicenses();
  await initFirebase(useEmulators: _useEmulators);

  final db = FirebaseFirestore.instance;
  runApp(
    NairaSpendApp(
      auth: FirebaseAuthRepository(FirebaseAuth.instance),
      createSession: (uid) => UserSession(
        uid: uid,
        expenses: FirestoreExpenseRepository(db, uid),
        budgets: FirestoreBudgetRepository(db, uid),
        clock: DateTime.now,
      ),
      clock: DateTime.now,
    ),
  );
}
