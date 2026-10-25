import 'package:flutter/material.dart';

/// A rounded horizontal bar filled to [value] (0 to 1).
///
/// Decorative: the amount it shows is always written next to it in words.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height);
    return ExcludeSemantics(
      child: Container(
        height: height,
        decoration: BoxDecoration(color: trackColor, borderRadius: radius),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: radius),
          ),
        ),
      ),
    );
  }
}
