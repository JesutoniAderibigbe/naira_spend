import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/repositories/auth_repository.dart';
import 'package:naira_spend/logic/controllers/auth_controller.dart';
import 'package:naira_spend/ui/screens/sign_in_screen.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

import '../../fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthController auth;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = FakeAuthRepository();
    auth = AuthController(repository);
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: SignInScreen(controller: auth),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the pitch and both options', (tester) async {
    await pump(tester);
    expect(find.text('Know where every naira goes.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Try it as a guest'), findsOneWidget);
    expect(find.textContaining('Guest data stays on this phone'), findsOne);
  });

  testWidgets('Try it as a guest signs in anonymously', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('signIn.guest')));
    await tester.pumpAndSettle();
    expect(repository.currentUser!.isGuest, isTrue);
  });

  testWidgets('Continue with Google signs in with Google', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('signIn.google')));
    await tester.pumpAndSettle();
    expect(repository.currentUser!.isGuest, isFalse);
  });

  testWidgets('a failed sign-in is explained in words', (tester) async {
    await pump(tester);
    repository.failNext = const AuthFailure('Sign-in was cancelled.');
    await tester.tap(find.byKey(const ValueKey('signIn.google')));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in was cancelled.'), findsOneWidget);
    expect(repository.currentUser, isNull);
  });
}
