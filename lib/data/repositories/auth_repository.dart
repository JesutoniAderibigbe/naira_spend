import '../models/app_user.dart';

/// Signs people in with Google or as a guest.
abstract interface class AuthRepository {
  /// Emits the current user straight away (null when signed out), then on
  /// every change.
  Stream<AppUser?> watchUser();

  AppUser? get currentUser;

  /// Signs in with Google. A guest is upgraded in place (the anonymous
  /// account is linked), so their expenses and budgets are kept.
  Future<void> signInWithGoogle();

  Future<void> signInAsGuest();

  Future<void> signOut();
}

/// A sign-in problem worth telling the user about.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}
