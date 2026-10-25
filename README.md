# Naira Spend

A personal expense tracker in naira, built with Flutter and Firebase. Log what
you spend, set monthly budgets per category, and see where your money went.

## Features

- **Sign in** with Google, or try it as a guest. A guest who signs in later keeps their data (the anonymous account is linked).
- **Home**: spent this week, daily average, a 7-day bar chart (`fl_chart`), and recent expenses with delete.
- **Add expense**: amount in ₦, title, category (Food, Transport, Data, Bills, Fun, Other), date, and validation.
- **Budgets**: monthly limit per category with a progress bar. Status is always written in words ("Near limit", "At limit", "Over by ₦X"), never shown by colour alone.
- **Insights**: totals and category share for 7 days, 30 days or this month, plus the biggest single expense.
- Works offline after first load (Firestore cache). Dates use Lagos time.

## Architecture

```text
lib/
  logic/              pure Dart: money, budgets, spending, insights, validation
  logic/controllers/  screen controllers (home, add expense, budgets, insights, auth)
  data/               Firebase setup
  ui/screens/         sign in, home, add expense, budgets, insights
  ui/widgets/         cards, chart, progress bar, expense tile
  ui/theme/           palette, typography and colours from Figma design tokens
```

Routing uses `go_router`. The app runs with **Marionette** so an AI agent can
drive and screenshot it through MCP (see `.mcp.json` and `AGENTS.md`).

## Getting started

```bash
fvm use                      # Flutter version pinned in .fvmrc
cp lib/firebase_options.example.dart lib/firebase_options.dart
flutterfire configure        # or fill in your own Firebase project
flutter pub get
flutter run
```

Firebase client config files are git-ignored, so each developer uses their own project.
To run against the local emulators, use `firebase emulators:start`.

## Docs

`docs/SPEC.md` · `docs/DATA_MODEL.md` · `docs/DESIGN.md` · `docs/PLAN.md`

## Tests

```bash
flutter test
```
