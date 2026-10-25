import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/repositories/auth_repository.dart';
import 'logic/controllers/auth_controller.dart';
import 'logic/controllers/user_session.dart';
import 'ui/router.dart';
import 'ui/theme/app_theme.dart';

/// Root widget: auth, one [UserSession] per signed-in user, and the router.
class NairaSpendApp extends StatefulWidget {
  const NairaSpendApp({
    super.key,
    required this.auth,
    required this.createSession,
    required this.clock,
  });

  final AuthRepository auth;
  final SessionFactory createSession;
  final DateTime Function() clock;

  @override
  State<NairaSpendApp> createState() => _NairaSpendAppState();
}

class _NairaSpendAppState extends State<NairaSpendApp> {
  late final _auth = AuthController(widget.auth);
  late final GoRouter _router = buildRouter(
    auth: _auth,
    session: _currentSession,
    clock: widget.clock,
  );
  UserSession? _session;

  /// The session for the signed-in user, created (or swapped) on demand.
  /// Only called by routes that require a signed-in user.
  UserSession _currentSession() {
    final uid = _auth.user!.uid;
    final current = _session;
    if (current?.uid == uid) return current!;
    _retire(current);
    return _session = widget.createSession(uid);
  }

  void _onAuthChanged() {
    final user = _auth.user;
    if (_session != null && _session!.uid != user?.uid) {
      _retire(_session);
      _session = null;
    }
  }

  /// Disposes a session after the frame, once screens using it are gone.
  void _retire(UserSession? session) {
    if (session == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => session.dispose());
  }

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _router.dispose();
    _session?.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Naira Spend',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
