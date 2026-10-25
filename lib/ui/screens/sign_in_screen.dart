import 'package:flutter/material.dart';

import '../../logic/controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

/// Sign in: "Continue with Google" or "Try it as a guest".
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: _Logo(),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Know where every naira goes.',
                        style: AppTypography.display,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Log spending in seconds, set monthly budgets, and '
                        'see your week at a glance.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _Preview(),
                      const Spacer(),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const ValueKey('signIn.google'),
                        onPressed: controller.isBusy
                            ? null
                            : controller.signInWithGoogle,
                        icon: const _GoogleMark(),
                        label: const Text('Continue with Google'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        key: const ValueKey('signIn.guest'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                        onPressed: controller.isBusy
                            ? null
                            : controller.signInAsGuest,
                        child: const Text('Try it as a guest'),
                      ),
                      if (controller.error case final error?) ...[
                        const SizedBox(height: 12),
                        Text(
                          error,
                          key: const ValueKey('signIn.error'),
                          textAlign: TextAlign.center,
                          style: AppTypography.smallMedium.copyWith(
                            color: scheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        'Guest data stays on this phone until you sign in. '
                        'Signing in later keeps it in your account.',
                        textAlign: TextAlign.center,
                        style: AppTypography.small.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '₦',
        semanticsLabel: 'Naira Spend',
        style: AppTypography.h2.copyWith(color: scheme.onPrimary),
      ),
    );
  }
}

/// A picture of the Home summary, to show what the app does.
class _Preview extends StatelessWidget {
  const _Preview();

  // Bar heights as a share of the tallest, as in the Figma frame.
  static const _bars = [0.1, 0.45, 0.25, 1.0, 0.15, 0.3, 0.35];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    return ExcludeSemantics(
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Spent this week',
                    style: AppTypography.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text('₦45,800', style: AppTypography.amountSmall),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (i, height) in _bars.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: height,
                        alignment: Alignment.bottomCenter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: height == 1
                                ? colors.chartBarHighlight
                                : colors.chartBar.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white "G" circle on the Google button.
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 12,
      backgroundColor: scheme.onPrimary,
      child: Text(
        'G',
        style: AppTypography.captionStrong.copyWith(color: scheme.primary),
      ),
    );
  }
}
