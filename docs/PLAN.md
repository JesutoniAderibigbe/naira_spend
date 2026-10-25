# Build plan

Follows AGENTS.md: three layers, go_router, ChangeNotifier controllers,
money as int kobo, days and months in Africa/Lagos time.

## Folders

```
lib/
  main.dart                    bootstrap: Firebase, emulators, runApp
  app.dart                     MaterialApp.router + AppTheme.light
  data/                        no Flutter imports
    models/
      category.dart            enum Category (food … other)
      expense.dart             Expense
      budget.dart              Budget (category, monthlyLimitKobo)
    repositories/
      auth_repository.dart             interface
      firebase_auth_repository.dart    Google + anonymous, link guest
      expense_repository.dart          interface
      firestore_expense_repository.dart
      budget_repository.dart           interface
      firestore_budget_repository.dart
  logic/                       pure functions + controllers, no Firebase
    money.dart                 formatNaira, parseNairaToKobo
    lagos_time.dart            Lagos day/month boundaries
    spending.dart              weekly summary, category totals
    budget_status.dart         BudgetStatus, budgetStatus()
    insights.dart              (later) shares, biggest expense
    expense_validation.dart    (later) add-expense form rules
    controllers/
      auth_controller.dart
      home_controller.dart
      add_expense_controller.dart
      budgets_controller.dart
      insights_controller.dart
  ui/
    router.dart                GoRouter, routes, auth redirect
    theme/                     palette, typography, BudgetStatusColors
    screens/
      sign_in_screen.dart
      home_screen.dart
      add_expense_screen.dart
      budgets_screen.dart
      insights_screen.dart
      app_shell.dart           bottom navigation
    widgets/
      spend_bar_chart.dart     (fl_chart, added when Home is built)
      expense_tile.dart
      budget_progress_card.dart
      category_chip.dart
```

## Routes (go_router)

| Path | Screen | Notes |
|---|---|---|
| `/sign-in` | SignInScreen | Only route when signed out |
| `/` | HomeScreen | Tab 1 in a `StatefulShellRoute` |
| `/budgets` | BudgetsScreen | Tab 2 |
| `/insights` | InsightsScreen | Tab 3 |
| `/add-expense` | AddExpenseScreen | Full screen above the shell |

Redirect: signed out → `/sign-in`; signed in on `/sign-in` → `/`.
The router listens to `AuthController` (a ChangeNotifier).

## Data flow

Firestore → repository (interface) → controller (ChangeNotifier) →
`ListenableBuilder` in a screen. Controllers get repositories and a clock
(`DateTime Function()`) through their constructors. Pure functions take
`now` as a parameter.

## Pure functions, tested first

Done in this step:

1. `money.dart`: `formatNaira(int kobo)` and `parseNairaToKobo(String)`.
2. `lagos_time.dart`: `lagosDay`, `lagosMonthRange`, `lagosLastDaysRange`.
3. `spending.dart`: `weeklySummary` (last 7 Lagos days, zero-filled,
   total, daily average) and `categoryTotals` / `monthlyCategoryTotals`.
4. `budget_status.dart`: `budgetStatus(spentKobo, limitKobo)` → fine,
   near limit, at limit, over by X, with the label in words.

Next, before their screens:

5. `expense_validation.dart`: amount, title and date rules for the form.
6. `insights.dart`: per-category share for 7 days / 30 days / this month,
   biggest single expense.
7. `anyOverBudget` for the Budgets alert.

## Open questions

- "Spent this week" is treated as the last 7 Lagos days including today
  (same window as the bar chart), not Monday to Sunday.
- The spec gives no words for the "fine" status. The label is "On track"
  until you choose one.
