import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/expense_repository.dart';
import 'budgets_controller.dart';
import 'home_controller.dart';
import 'insights_controller.dart';

/// Everything that belongs to one signed-in user. Created on sign-in and
/// disposed on sign-out, so no data leaks between accounts.
class UserSession {
  UserSession({
    required this.uid,
    required this.expenses,
    required this.budgets,
    required this.clock,
  }) : home = HomeController(expenses: expenses, clock: clock),
       budgetsController = BudgetsController(
         budgets: budgets,
         expenses: expenses,
         clock: clock,
       ),
       insights = InsightsController(expenses: expenses, clock: clock);

  final String uid;
  final ExpenseRepository expenses;
  final BudgetRepository budgets;
  final DateTime Function() clock;

  final HomeController home;
  final BudgetsController budgetsController;
  final InsightsController insights;

  void dispose() {
    home.dispose();
    budgetsController.dispose();
    insights.dispose();
  }
}

/// Builds the repositories for a user: Firestore in the app, in-memory in
/// tests.
typedef SessionFactory = UserSession Function(String uid);
