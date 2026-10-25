import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import 'app_palette.dart';

/// Figma colours that have no slot in [ColorScheme], read with
/// `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bodyText,
    required this.chartBar,
    required this.chartBarHighlight,
    required this.track,
    required this.alert,
    required this.tip,
    required this.categories,
  });

  /// Secondary text, e.g. "Daily average".
  final Color bodyText;

  /// Bars in the spend chart, and the highlighted (highest) bar.
  final Color chartBar;
  final Color chartBarHighlight;

  /// Empty part of a share bar (Insights).
  final Color track;

  /// Over-budget alert box (Budgets) and the tip box (Insights).
  final MessageColors alert;
  final MessageColors tip;

  /// Background and foreground for each category's icon tile.
  final Map<Category, CategoryColor> categories;

  CategoryColor category(Category category) => categories[category]!;

  static const light = AppColors(
    bodyText: AppPalette.bodyText,
    chartBar: AppPalette.chartMuted,
    chartBarHighlight: AppPalette.primary,
    track: AppPalette.track,
    alert: MessageColors(
      background: AppPalette.dangerBg,
      border: AppPalette.dangerBorder,
      foreground: AppPalette.dangerInk,
      icon: AppPalette.dangerText,
    ),
    tip: MessageColors(
      background: AppPalette.warningBg,
      border: AppPalette.warningBorder,
      foreground: AppPalette.warningInk,
      icon: AppPalette.warningText,
    ),
    categories: {
      Category.food: CategoryColor(AppPalette.foodBg, AppPalette.foodFg),
      Category.transport: CategoryColor(
        AppPalette.transportBg,
        AppPalette.transportFg,
      ),
      Category.data: CategoryColor(AppPalette.dataBg, AppPalette.dataFg),
      Category.bills: CategoryColor(AppPalette.billsBg, AppPalette.billsFg),
      Category.fun: CategoryColor(AppPalette.funBg, AppPalette.funFg),
      Category.other: CategoryColor(AppPalette.otherBg, AppPalette.otherFg),
    },
  );

  @override
  AppColors copyWith({
    Color? bodyText,
    Color? chartBar,
    Color? chartBarHighlight,
    Color? track,
    MessageColors? alert,
    MessageColors? tip,
    Map<Category, CategoryColor>? categories,
  }) {
    return AppColors(
      bodyText: bodyText ?? this.bodyText,
      chartBar: chartBar ?? this.chartBar,
      chartBarHighlight: chartBarHighlight ?? this.chartBarHighlight,
      track: track ?? this.track,
      alert: alert ?? this.alert,
      tip: tip ?? this.tip,
      categories: categories ?? this.categories,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      chartBar: Color.lerp(chartBar, other.chartBar, t)!,
      chartBarHighlight: Color.lerp(
        chartBarHighlight,
        other.chartBarHighlight,
        t,
      )!,
      track: Color.lerp(track, other.track, t)!,
      alert: MessageColors.lerp(alert, other.alert, t),
      tip: MessageColors.lerp(tip, other.tip, t),
      categories: {
        for (final c in Category.values)
          c: CategoryColor.lerp(category(c), other.category(c), t),
      },
    );
  }
}

@immutable
class CategoryColor {
  const CategoryColor(this.background, this.foreground);

  final Color background;
  final Color foreground;

  static CategoryColor lerp(CategoryColor a, CategoryColor b, double t) =>
      CategoryColor(
        Color.lerp(a.background, b.background, t)!,
        Color.lerp(a.foreground, b.foreground, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is CategoryColor &&
      other.background == background &&
      other.foreground == foreground;

  @override
  int get hashCode => Object.hash(background, foreground);
}

/// Colours for a bordered message box with an icon.
@immutable
class MessageColors {
  const MessageColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color icon;

  static MessageColors lerp(MessageColors a, MessageColors b, double t) =>
      MessageColors(
        background: Color.lerp(a.background, b.background, t)!,
        border: Color.lerp(a.border, b.border, t)!,
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        icon: Color.lerp(a.icon, b.icon, t)!,
      );
}
