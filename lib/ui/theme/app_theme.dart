import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_typography.dart';
import 'budget_status_colors.dart';

export 'app_colors.dart';
export 'app_typography.dart';
export 'budget_status_colors.dart';

/// App themes built from the Figma tokens.
///
/// Figma has a light mode only, so there is no dark theme yet. Add [dark]
/// when a dark mode exists in the Figma "Colour" collection.
abstract final class AppTheme {
  static final light = _build(
    ColorScheme.fromSeed(seedColor: AppPalette.primary).copyWith(
      primary: AppPalette.primary,
      onPrimary: AppPalette.white,
      primaryContainer: AppPalette.container,
      onPrimaryContainer: AppPalette.primaryText,
      secondary: AppPalette.primaryText,
      onSecondary: AppPalette.white,
      error: AppPalette.danger,
      onError: AppPalette.white,
      errorContainer: AppPalette.dangerBg,
      onErrorContainer: AppPalette.dangerInk,
      surface: AppPalette.surface,
      onSurface: AppPalette.ink,
      onSurfaceVariant: AppPalette.muted,
      surfaceContainerLowest: AppPalette.white,
      surfaceContainerLow: AppPalette.white,
      surfaceContainer: AppPalette.divider,
      surfaceContainerHigh: AppPalette.segmentBg,
      surfaceContainerHighest: AppPalette.segmentBg,
      outline: AppPalette.borderStrong,
      outlineVariant: AppPalette.border,
    ),
    budgetStatus: BudgetStatusColors.light,
    colors: AppColors.light,
  );

  static ThemeData _build(
    ColorScheme scheme, {
    required BudgetStatusColors budgetStatus,
    required AppColors colors,
  }) {
    final textTheme = AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppTypography.manrope,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(color: scheme.surfaceContainer),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: _radius16),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          foregroundColor: scheme.onSurface,
          backgroundColor: scheme.surfaceContainerLowest,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(borderRadius: _radius16),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onPrimaryContainer,
          textStyle: AppTypography.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: AppTypography.body.copyWith(color: scheme.onSurfaceVariant),
        border: _inputBorder(scheme.outline),
        enabledBorder: _inputBorder(scheme.outline),
        focusedBorder: _inputBorder(scheme.primary, width: 2),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppTypography.smallStrong.copyWith(
                  color: scheme.onPrimaryContainer,
                )
              : AppTypography.small.copyWith(color: scheme.onSurfaceVariant),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [budgetStatus, colors],
    );
  }

  static final _radius16 = BorderRadius.circular(16);

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}
