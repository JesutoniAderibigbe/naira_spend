import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/ui/theme/app_palette.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    final theme = AppTheme.light;

    test('uses the Figma core colours', () {
      final scheme = theme.colorScheme;
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, AppPalette.primary);
      expect(scheme.onPrimary, AppPalette.white);
      expect(scheme.surface, AppPalette.surface);
      expect(scheme.onSurface, AppPalette.ink);
      expect(scheme.onSurfaceVariant, AppPalette.muted);
      expect(scheme.error, AppPalette.danger);
      expect(scheme.outlineVariant, AppPalette.border);
    });

    test('registers BudgetStatusColors', () {
      final status = theme.extension<BudgetStatusColors>();
      expect(status, BudgetStatusColors.light);
      expect(status!.fine.indicator, AppPalette.primary);
      expect(status.near.indicator, AppPalette.warning);
      expect(status.over.indicator, AppPalette.danger);
    });

    test('at limit is amber like near limit, as in the Figma frame', () {
      final status = BudgetStatusColors.light;
      expect(status.atLimit, status.near);
      expect(status.atLimit.indicator, AppPalette.warning);
      expect(status.atLimit, isNot(status.over));
    });

    test('text theme uses Sora for headings and Manrope for body', () {
      final text = theme.textTheme;
      expect(text.displayLarge!.fontFamily, 'Sora');
      expect(text.headlineLarge!.fontFamily, 'Sora');
      expect(text.bodyLarge!.fontFamily, 'Manrope');
      expect(text.labelLarge!.fontFamily, 'Manrope');
      expect(text.bodyLarge!.color, AppPalette.ink);
    });
  });

  group('BudgetStatusColors', () {
    const light = BudgetStatusColors.light;

    test('lerp returns the ends at 0 and 1', () {
      final other = light.copyWith(fine: light.over);
      expect(light.lerp(other, 0), light);
      expect(light.lerp(other, 1), other);
    });

    test('lerp with null keeps the current colours', () {
      expect(light.lerp(null, 0.5), light);
    });

    test('copyWith replaces only the given status', () {
      final copy = light.copyWith(near: light.fine);
      expect(copy.near, light.fine);
      expect(copy.fine, light.fine);
      expect(copy.over, light.over);
    });
  });

  group('AppTypography matches the Figma export', () {
    final tokens =
        jsonDecode(File('docs/design-tokens.tokens.json').readAsStringSync())
            as Map<String, dynamic>;
    final font = tokens['font'] as Map<String, dynamic>;

    final styles = <String, TextStyle>{
      'heading/display': AppTypography.display,
      'heading/h1': AppTypography.h1,
      'heading/h2': AppTypography.h2,
      'heading/h3': AppTypography.h3,
      'heading/monogram': AppTypography.monogram,
      'amount/hero': AppTypography.amountHero,
      'amount/large': AppTypography.amountLarge,
      'amount/medium': AppTypography.amountMedium,
      'amount/small': AppTypography.amountSmall,
      'amount/row': AppTypography.amountRow,
      'body/large': AppTypography.bodyLarge,
      'body/button': AppTypography.button,
      'body/title': AppTypography.title,
      'body/default': AppTypography.body,
      'body/default medium': AppTypography.bodyMedium,
      'body/strong': AppTypography.strong,
      'body/small': AppTypography.small,
      'body/small medium': AppTypography.smallMedium,
      'body/small strong': AppTypography.smallStrong,
      'body/caption': AppTypography.caption,
      'body/caption strong': AppTypography.captionStrong,
      'body/tiny': AppTypography.tiny,
      'body/tiny strong': AppTypography.tinyStrong,
    };

    test('every Figma text style has a Dart style', () {
      final figmaNames = [
        for (final group in font.entries)
          for (final name in (group.value as Map<String, dynamic>).keys)
            '${group.key}/$name',
      ];
      expect(styles.keys, unorderedEquals(figmaNames));
    });

    for (final MapEntry(key: path, value: style) in styles.entries) {
      test(path, () {
        final parts = path.split('/');
        final value =
            ((font[parts[0]] as Map<String, dynamic>)[parts[1]]
                    as Map<String, dynamic>)['value']
                as Map<String, dynamic>;
        final weight = value['fontWeight'] as int;

        expect(style.fontFamily, value['fontFamily']);
        expect(style.fontSize, value['fontSize']);
        expect(style.fontWeight!.value, weight);
        expect(style.fontVariations, [
          FontVariation('wght', weight.toDouble()),
        ]);
        expect(style.letterSpacing, value['letterSpacing']);
        expect(
          style.height! * style.fontSize!,
          moreOrLessEquals((value['lineHeight'] as num).toDouble()),
        );
      });
    }
  });
}
