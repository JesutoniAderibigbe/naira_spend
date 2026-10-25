import 'dart:async';

import 'package:naira_spend/data/models/app_user.dart';
import 'package:naira_spend/data/repositories/auth_repository.dart';
import 'package:naira_spend/data/repositories/budget_repository.dart';
import 'package:naira_spend/data/repositories/current_then_changes.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/user_session.dart';

/// In-memory auth for tests. Google sign-in upgrades a guest in place.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? user}) {
    _user = user;
  }

  AppUser? _user;
  final _changes = StreamController<AppUser?>.broadcast();
  var _nextUid = 0;

  /// When set, the next sign-in throws this.
  AuthFailure? failNext;

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> watchUser() =>
      currentThenChanges(() => _user, _changes.stream);

  void _set(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  void _maybeFail() {
    final failure = failNext;
    failNext = null;
    if (failure != null) throw failure;
  }

  @override
  Future<void> signInAsGuest() async {
    _maybeFail();
    _set(AppUser(uid: 'guest-${_nextUid++}', isGuest: true));
  }

  @override
  Future<void> signInWithGoogle() async {
    _maybeFail();
    _set(
      AppUser(
        uid: _user?.uid ?? 'google-${_nextUid++}',
        isGuest: false,
        displayName: 'Jane Ade',
      ),
    );
  }

  @override
  Future<void> signOut() async => _set(null);
}

/// Sessions backed by in-memory repositories, one set per uid, so data
/// survives signing out and back in as in Firestore.
class FakeSessions {
  FakeSessions({this.clock = _defaultClock, this.seed});

  final DateTime Function() clock;

  /// Repositories to use for the first session (e.g. placeholder data).
  final InMemoryExpenseRepository? seed;

  final expenses = <String, InMemoryExpenseRepository>{};
  final budgets = <String, InMemoryBudgetRepository>{};

  static DateTime _defaultClock() => DateTime.utc(2026, 10, 9, 12);

  UserSession create(String uid) => UserSession(
    uid: uid,
    expenses: expenses.putIfAbsent(
      uid,
      () => expenses.isEmpty && seed != null
          ? seed!
          : InMemoryExpenseRepository(),
    ),
    budgets: budgets.putIfAbsent(uid, InMemoryBudgetRepository.new),
    clock: clock,
  );
}
