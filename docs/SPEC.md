# Naira Spend Tracker: spec

## Users
People tracking personal spending, signed in with Google or as a guest.
A guest who later signs in keeps their data (link the anonymous account).

## Screens
1. Sign in: "Continue with Google", "Try it as a guest".
2. Home: spent this week, daily average, bar chart of spend per day
   (last 7 days), recent expenses with delete, "Add expense" button.
3. Add expense: amount (₦), title, category (Food, Transport, Data,
   Bills, Fun, Other), date (default today), validation.
4. Budgets: monthly limit per category, progress bar, status text,
   alert when any category is over budget.
5. Insights: total and per-category share for 7 days, 30 days or
   this month, plus the biggest single expense.

## Rules
- Budget status: under 80% is fine, 80% to 99% is "Near limit",
  exactly 100% is "At limit", above 100% is "Over by ₦X".
- Status is always written in words, never shown by colour alone.
- Works offline after first load (Firestore cache).

## Out of scope for v1
Bank sync, multiple currencies, shared budgets, push notifications.