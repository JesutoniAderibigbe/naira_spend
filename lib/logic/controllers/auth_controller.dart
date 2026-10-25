import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

/// Who is signed in. The router listens to this to redirect.
class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository.watchUser().listen((user) {
      _user = user;
      _isReady = true;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  AppUser? _user;
  bool _isReady = false;
  bool _isBusy = false;
  String? _error;

  AppUser? get user => _user;

  /// False until the saved sign-in (if any) has been restored.
  bool get isReady => _isReady;
  bool get isBusy => _isBusy;

  /// The last sign-in problem, in words. Cleared on the next attempt.
  String? get error => _error;

  Future<void> signInWithGoogle() => _run(_repository.signInWithGoogle);

  Future<void> signInAsGuest() => _run(_repository.signInAsGuest);

  Future<void> signOut() => _run(_repository.signOut);

  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy) return;
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on AuthFailure catch (e) {
      _error = e.message;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
