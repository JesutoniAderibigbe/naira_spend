import 'package:flutter/material.dart';

import '../../logic/controllers/auth_controller.dart';
import '../theme/app_theme.dart';

/// Account options: a guest can sign in with Google (keeping their data);
/// anyone can sign out.
Future<void> showAccountSheet(BuildContext context, AuthController auth) {
  return showModalBottomSheet<void>(
    context: context,
    // Above the bottom navigation bar, not inside the tab.
    useRootNavigator: true,
    showDragHandle: true,
    builder: (context) => ListenableBuilder(
      listenable: auth,
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final user = auth.user;
        if (user == null) return const SizedBox.shrink();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  user.isGuest
                      ? 'You are using Naira Spend as a guest'
                      : 'Signed in as ${user.displayName ?? 'Google user'}',
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  user.isGuest
                      ? 'Sign in with Google to keep your expenses and budgets '
                            'in your account. Signing out as a guest deletes '
                            'access to them.'
                      : 'Your expenses and budgets are saved to your account.',
                  style: AppTypography.small.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                if (user.isGuest) ...[
                  FilledButton(
                    key: const ValueKey('account.google'),
                    onPressed: auth.isBusy ? null : auth.signInWithGoogle,
                    child: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  key: const ValueKey('account.signOut'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: auth.isBusy
                      ? null
                      : () async {
                          Navigator.of(context).pop();
                          await auth.signOut();
                        },
                  child: const Text('Sign out'),
                ),
                if (auth.error case final error?) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    key: const ValueKey('account.error'),
                    textAlign: TextAlign.center,
                    style: AppTypography.smallMedium.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
