import 'package:flutter/painting.dart';

/// Colour variables from the Figma "Colour" collection
/// (docs/design-tokens.tokens.json). Light mode only.
///
/// This is the only file in the app allowed to contain hex colour values.
/// Widgets read colours through `Theme.of(context).colorScheme` or a theme
/// extension such as `BudgetStatusColors`, never from here directly.
abstract final class AppPalette {
  // Core
  static const primary = Color(0xFF008751);
  static const primaryText = Color(0xFF006B40);
  static const ink = Color(0xFF14201A);
  static const surface = Color(0xFFF7F9F7);
  static const container = Color(0xFFE3F1E8);
  static const muted = Color(0xFF4E5D55);
  static const warning = Color(0xFFD98B00);
  static const danger = Color(0xFFC0392B);

  // Support
  static const white = Color(0xFFFFFFFF);
  static const bodyText = Color(0xFF3E4B44);
  static const border = Color(0xFFDCE5DF);
  static const borderStrong = Color(0xFFB8C6BD);
  static const divider = Color(0xFFEEF2EF);
  static const track = Color(0xFFEEF2EF);
  static const segmentBg = Color(0xFFE8EEEA);
  static const chartMuted = Color(0xFF9CCBB0);
  static const chartFaint = Color(0xFFB9D9C6);
  static const primaryTrack = Color(0xFFD5E9DC);

  static const warningTrack = Color(0xFFF7E6C2);
  static const warningText = Color(0xFF7A4A00);
  static const warningBg = Color(0xFFFFF6E0);
  static const warningBorder = Color(0xFFF2D58F);
  static const warningInk = Color(0xFF5A3700);

  static const dangerTrack = Color(0xFFF3D3CE);
  static const dangerText = Color(0xFFA3271A);
  static const dangerInk = Color(0xFF7A1D13);
  static const dangerBg = Color(0xFFFDECEA);
  static const dangerBorder = Color(0xFFF1B2AA);

  // Category
  static const foodBg = Color(0xFFFDEFD2);
  static const foodFg = Color(0xFF7A4A00);
  static const transportBg = Color(0xFFE1ECFB);
  static const transportFg = Color(0xFF1D4F91);
  static const dataBg = Color(0xFFEAE3FA);
  static const dataFg = Color(0xFF4B2A99);
  static const billsBg = Color(0xFFFDE7E4);
  static const billsFg = Color(0xFFA3271A);
  static const funBg = Color(0xFFFCE4F1);
  static const funFg = Color(0xFF8E1F5B);
  static const otherBg = Color(0xFFE8EEEA);
  static const otherFg = Color(0xFF3E4B44);
}
