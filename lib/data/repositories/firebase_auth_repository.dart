import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

final _log = Logger('auth');

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          isGuest: user.isAnonymous,
          // A guest linked to Google keeps an empty top-level name; the
          // Google name is on the linked provider.
          displayName:
              user.displayName ??
              user.providerData.map((p) => p.displayName).nonNulls.firstOrNull,
        );

  @override
  Stream<AppUser?> watchUser() => _auth.userChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();
    final guest = _auth.currentUser;
    try {
      if (guest != null && guest.isAnonymous) {
        // Keeps the guest's uid, and with it their Firestore data.
        await (kIsWeb
            ? guest.linkWithPopup(provider)
            : guest.linkWithProvider(provider));
      } else {
        await (kIsWeb
            ? _auth.signInWithPopup(provider)
            : _auth.signInWithProvider(provider));
      }
    } on FirebaseAuthException catch (e) {
      _log.warning('Google sign-in failed: ${e.code}', e);
      throw AuthFailure(_messageFor(e.code));
    }
  }

  @override
  Future<void> signInAsGuest() async {
    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      _log.warning('Guest sign-in failed: ${e.code}', e);
      throw AuthFailure(_messageFor(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static String _messageFor(String code) => switch (code) {
    'credential-already-in-use' || 'email-already-in-use' =>
      'That Google account already has Naira Spend data. Sign out of the '
          'guest account first to use it.',
    'web-context-canceled' ||
    'web-context-cancelled' ||
    'popup-closed-by-user' ||
    'canceled' => 'Sign-in was cancelled.',
    'network-request-failed' => 'No connection. Try again when you are online.',
    'operation-not-allowed' =>
      'This sign-in method is not turned on for the project yet.',
    'user-token-expired' ||
    'user-disabled' ||
    'user-not-found' ||
    'invalid-user-token' =>
      'Your session has expired. Sign out and sign in again.',
    _ => 'Could not sign in. Please try again.',
  };
}
