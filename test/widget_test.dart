import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/app.dart';
import 'package:naira_spend/data/models/app_user.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';

import 'fakes.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);

void main() {
  late FakeAuthRepository auth;
  late FakeSessions sessions;

  Future<void> pumpApp(WidgetTester tester, {AppUser? user}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    auth = FakeAuthRepository(user: user);
    sessions = FakeSessions(
      clock: () => _now,
      seed: InMemoryExpenseRepository.placeholder(_now),
    );
    await tester.pumpWidget(
      NairaSpendApp(
        auth: auth,
        createSession: sessions.create,
        clock: () => _now,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('signed out starts on Sign in', (tester) async {
    await pumpApp(tester);
    expect(find.text('Know where every naira goes.'), findsOneWidget);
    expect(find.byKey(const ValueKey('nav.home')), findsNothing);
  });

  testWidgets('a saved sign-in goes straight to Home', (tester) async {
    await pumpApp(tester, user: const AppUser(uid: 'u1', isGuest: false));
    expect(find.text('Your money'), findsOneWidget);
  });

  testWidgets('guest → add expense → budgets → insights → sign out', (
    tester,
  ) async {
    await pumpApp(tester);

    // Sign in as a guest: Home with placeholder data.
    await tap(tester, 'signIn.guest');
    expect(find.text('Your money'), findsOneWidget);
    Text total() =>
        tester.widget<Text>(find.byKey(const ValueKey('home.weekTotal')));
    expect(total().data, '₦45,800');

    // Add an expense; Home updates.
    await tap(tester, 'home.addExpense');
    expect(find.text('Add expense'), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.amount')),
      '2500',
    );
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.title')),
      'Puff-puff',
    );
    await tap(tester, 'category.food');
    await tap(tester, 'addExpense.save');
    expect(find.text('Saved Puff-puff'), findsOneWidget);
    expect(total().data, '₦48,300');
    expect(find.text('Puff-puff'), findsOneWidget);

    // Budgets: empty, then set a Food limit that is already over.
    // Food this month: 4,500 + 3,800 + 4,800 + 2,500 = ₦15,600.
    await tap(tester, 'nav.budgets');
    expect(find.byKey(const ValueKey('budgets.empty')), findsOneWidget);
    await tap(tester, 'budgets.edit');
    await tester.enterText(
      find.byKey(const ValueKey('budgetEdit.food')),
      '10000',
    );
    await tap(tester, 'budgetEdit.save');
    expect(find.text('Food is ₦5,600 over budget'), findsOneWidget);
    expect(find.text('Over by ₦5,600'), findsOneWidget);

    // Insights: 30 days by default.
    await tap(tester, 'nav.insights');
    expect(find.text('Spent in the last 30 days'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('insights.total'))).data,
      '₦50,800',
    );
    await tap(tester, 'insights.period.last7Days');
    expect(find.text('Spent in the last 7 days'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('insights.total'))).data,
      '₦48,300',
    );

    // Sign out from the account sheet on Home.
    await tap(tester, 'nav.home');
    await tap(tester, 'home.account');
    await tap(tester, 'account.signOut');
    expect(find.text('Know where every naira goes.'), findsOneWidget);
  });

  testWidgets('a guest who signs in with Google keeps their data', (
    tester,
  ) async {
    await pumpApp(tester);
    await tap(tester, 'signIn.guest');
    final guestUid = auth.currentUser!.uid;

    await tap(tester, 'home.account');
    await tap(tester, 'account.google');
    await tester.tapAt(const Offset(20, 20)); // close the sheet
    await tester.pumpAndSettle();

    expect(auth.currentUser!.uid, guestUid);
    expect(auth.currentUser!.isGuest, isFalse);
    expect(find.text('JA'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home.weekTotal'))).data,
      '₦45,800',
    );
  });
}
