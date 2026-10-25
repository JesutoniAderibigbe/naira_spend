import 'package:flutter/material.dart';

/// Text styles from Figma (docs/design-tokens.tokens.json).
///
/// Styles carry no colour, so they inherit it from the theme. Sora and
/// Manrope are bundled as variable fonts, so each style sets the `wght` axis
/// as well as [FontWeight].
abstract final class AppTypography {
  static const sora = 'Sora';
  static const manrope = 'Manrope';

  // Heading
  static final display = _style(sora, 40, 700, 43.2, letterSpacing: -0.8);
  static final h1 = _style(sora, 28, 700, 33.6);
  static final h2 = _style(sora, 24, 700, 28.8);
  static final h3 = _style(sora, 20, 700, 24);
  static final monogram = _style(sora, 16, 700, 19.2);

  // Amount
  static final amountHero = _style(sora, 40, 700, 48);
  static final amountLarge = _style(sora, 36, 700, 43.2, letterSpacing: -0.72);
  static final amountMedium = _style(sora, 34, 700, 40.8, letterSpacing: -0.68);
  static final amountSmall = _style(sora, 22, 700, 26.4);
  static final amountRow = _style(sora, 15, 600, 18);

  // Body
  static final bodyLarge = _style(manrope, 18, 400, 27);
  static final button = _style(manrope, 17, 700, 20.4);
  static final title = _style(manrope, 16, 700, 19.2);
  static final body = _style(manrope, 16, 400, 19.2);
  static final bodyMedium = _style(manrope, 16, 500, 19.2);
  static final strong = _style(manrope, 15, 700, 18);
  static final small = _style(manrope, 14, 400, 20.3);
  static final smallMedium = _style(manrope, 14, 500, 16.8);
  static final smallStrong = _style(manrope, 14, 700, 16.8);
  static final caption = _style(manrope, 13, 400, 19.5);
  static final captionStrong = _style(manrope, 13, 700, 15.6);
  static final tiny = _style(manrope, 12, 500, 14.4);
  static final tinyStrong = _style(manrope, 12, 700, 14.4);

  /// Material 3 text theme built from the Figma styles. Styles with no
  /// Material slot (amounts, monogram, ...) are used from [AppTypography]
  /// directly.
  static final textTheme = TextTheme(
    displayLarge: display,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    titleMedium: title,
    titleSmall: smallStrong,
    bodyLarge: body,
    bodyMedium: small,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: captionStrong,
    labelSmall: tiny,
  );

  static TextStyle _style(
    String family,
    double size,
    int weight,
    double lineHeight, {
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: FontWeight.values.firstWhere((w) => w.value == weight),
      fontVariations: [FontVariation('wght', weight.toDouble())],
      height: lineHeight / size,
      letterSpacing: letterSpacing,
    );
  }
}
