import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Colours for one budget status: the progress bar, its track, the status
/// text and the background of a status chip or alert.
///
/// Colour never carries the status on its own; the status is always written
/// in words as well (docs/SPEC.md).
@immutable
class BudgetStatusColor {
  const BudgetStatusColor({
    required this.indicator,
    required this.track,
    required this.text,
    required this.background,
  });

  final Color indicator;
  final Color track;
  final Color text;
  final Color background;

  static BudgetStatusColor lerp(
    BudgetStatusColor a,
    BudgetStatusColor b,
    double t,
  ) {
    return BudgetStatusColor(
      indicator: Color.lerp(a.indicator, b.indicator, t)!,
      track: Color.lerp(a.track, b.track, t)!,
      text: Color.lerp(a.text, b.text, t)!,
      background: Color.lerp(a.background, b.background, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BudgetStatusColor &&
      other.indicator == indicator &&
      other.track == track &&
      other.text == text &&
      other.background == background;

  @override
  int get hashCode => Object.hash(indicator, track, text, background);
}

/// Budget status colours, read with
/// `Theme.of(context).extension<BudgetStatusColors>()!`.
///
/// Under 80% is [fine], 80% to 99% is [near], exactly 100% is [atLimit] and
/// above 100% is [over].
@immutable
class BudgetStatusColors extends ThemeExtension<BudgetStatusColors> {
  const BudgetStatusColors({
    required this.fine,
    required this.near,
    required this.atLimit,
    required this.over,
  });

  final BudgetStatusColor fine;
  final BudgetStatusColor near;
  final BudgetStatusColor atLimit;
  final BudgetStatusColor over;

  static const light = BudgetStatusColors(
    fine: BudgetStatusColor(
      indicator: AppPalette.primary,
      track: AppPalette.primaryTrack,
      text: AppPalette.primaryText,
      background: AppPalette.container,
    ),
    // At limit is amber like near limit, as in the Figma Budgets frame; the
    // status text tells them apart.
    near: _warning,
    atLimit: _warning,
    over: BudgetStatusColor(
      indicator: AppPalette.danger,
      track: AppPalette.dangerTrack,
      text: AppPalette.dangerText,
      background: AppPalette.dangerBg,
    ),
  );

  static const _warning = BudgetStatusColor(
    indicator: AppPalette.warning,
    track: AppPalette.warningTrack,
    text: AppPalette.warningText,
    background: AppPalette.warningBg,
  );

  @override
  BudgetStatusColors copyWith({
    BudgetStatusColor? fine,
    BudgetStatusColor? near,
    BudgetStatusColor? atLimit,
    BudgetStatusColor? over,
  }) {
    return BudgetStatusColors(
      fine: fine ?? this.fine,
      near: near ?? this.near,
      atLimit: atLimit ?? this.atLimit,
      over: over ?? this.over,
    );
  }

  @override
  BudgetStatusColors lerp(BudgetStatusColors? other, double t) {
    if (other == null) return this;
    return BudgetStatusColors(
      fine: BudgetStatusColor.lerp(fine, other.fine, t),
      near: BudgetStatusColor.lerp(near, other.near, t),
      atLimit: BudgetStatusColor.lerp(atLimit, other.atLimit, t),
      over: BudgetStatusColor.lerp(over, other.over, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BudgetStatusColors &&
      other.fine == fine &&
      other.near == near &&
      other.atLimit == atLimit &&
      other.over == over;

  @override
  int get hashCode => Object.hash(fine, near, atLimit, over);
}
