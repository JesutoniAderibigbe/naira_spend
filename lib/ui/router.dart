import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/controllers/auth_controller.dart';
import '../logic/controllers/user_session.dart';
import 'screens/add_expense_screen.dart';
import 'screens/app_shell.dart';
import 'screens/budgets_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/sign_in_screen.dart';
import 'widgets/account_sheet.dart';

abstract final class Routes {
  static const loading = '/loading';
  static const signIn = '/sign-in';
  static const home = '/';
  static const budgets = '/budgets';
  static const insights = '/insights';
  static const addExpense = '/add-expense';
}

/// Signed out → /sign-in. Signed in → the tabs. Waits on /loading until the
/// saved sign-in has been restored.
String? authRedirect(AuthController auth, String location) {
  if (!auth.isReady) return location == Routes.loading ? null : Routes.loading;
  if (auth.user == null) {
    return location == Routes.signIn ? null : Routes.signIn;
  }
  if (location == Routes.signIn || location == Routes.loading) {
    return Routes.home;
  }
  return null;
}

GoRouter buildRouter({
  required AuthController auth,
  required UserSession Function() session,
  required DateTime Function() clock,
}) {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.home,
    refreshListenable: auth,
    redirect: (context, state) => authRedirect(auth, state.matchedLocation),
    routes: [
      GoRoute(
        path: Routes.loading,
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => SignInScreen(controller: auth),
      ),
      GoRoute(
        path: Routes.addExpense,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, _) => MaterialPage(
          fullscreenDialog: true,
          child: AddExpenseScreen(
            expenses: session().expenses,
            clock: clock,
            onDone: (savedTitle) {
              context.pop();
              if (savedTitle != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Saved $savedTitle')));
              }
            },
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                // Rebuilds when a guest signs in with Google (new name).
                builder: (context, _) => ListenableBuilder(
                  listenable: auth,
                  builder: (context, _) => auth.user == null
                      // Signed out; the redirect to /sign-in is on its way.
                      ? const SizedBox.shrink()
                      : HomeScreen(
                          controller: session().home,
                          displayName: auth.user?.displayName,
                          onAddExpense: () => context.push(Routes.addExpense),
                          onAccount: () => showAccountSheet(context, auth),
                        ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.budgets,
                builder: (_, _) =>
                    BudgetsScreen(controller: session().budgetsController),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.insights,
                builder: (_, _) =>
                    InsightsScreen(controller: session().insights),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
