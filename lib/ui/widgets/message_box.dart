import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A bordered box with an icon and text, for alerts and tips.
class MessageBox extends StatelessWidget {
  const MessageBox({
    super.key,
    required this.colors,
    required this.icon,
    required this.child,
  });

  final MessageColors colors;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTypography.small.copyWith(
                color: colors.foreground,
                fontSize: 15,
                height: 1.45,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
