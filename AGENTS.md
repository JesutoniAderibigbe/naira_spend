# Naira Spend Tracker: guide for AI agents

## Product
Read docs/SPEC.md for features and docs/DATA_MODEL.md for Firestore.
If a request conflicts with the spec, ask before building.

## Stack
- Flutter 3.44+, Material 3. Android first, web second.
- Firebase: Auth (Google + anonymous guest), Cloud Firestore.
- Routing: go_router. State: ChangeNotifier + ListenableBuilder.
- Layers: lib/data (models, repositories), lib/logic (controllers and
  pure functions), lib/ui (screens, widgets). UI never calls Firebase.

## Money
- Money is an int of kobo (100 kobo = 1 naira). Never double.
- Show amounts as ₦2,500 (whole naira) or ₦1,250.50. One formatter only.
- Months and days are calculated in Africa/Lagos time.

## Always
- Add packages with the pub tool. Say why each package is needed.
- After every change: analyze, fix all issues, format, run tests.
- Repositories have an interface so tests can use fakes
  (fake_cloud_firestore, firebase_auth_mocks).
- Inject a clock into anything that uses "now", so tests are exact.
- Put a Key on anything a test or agent taps.
- When the app is running: hot reload, check runtime errors, screenshot.
- Develop against the Firebase Emulator Suite, not production.

## Design
- Design tokens live in docs/design-tokens.json (exported from Figma with
  the Design Tokens plugin). This file is the source of truth.
- Use the Figma MCP only when the tokens file is missing something, and say
  so first: Figma calls are limited on the free plan.
- Colours and text styles come from lib/ui/theme, generated from the tokens
  file. Never hardcode a hex value in a widget.

## Never
- Never change a test to make it pass without telling me why.
- Never write or deploy Firestore security rules without showing me first.
- Never put API keys or service accounts in the repo.
- Never touch android/ or ios/ without asking (except FlutterFire config).
- Never initialize Marionette outside kDebugMode.

## Commands
flutter analyze · flutter test · dart format . · firebase emulators:start