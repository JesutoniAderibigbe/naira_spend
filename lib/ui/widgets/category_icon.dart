import 'package:flutter/material.dart';

import '../../data/models/category.dart';
import '../theme/app_theme.dart';

/// Rounded tile with the category's icon, in the category's colours.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.category, {super.key, this.size = 44});

  final Category category;
  final double size;

  static IconData iconFor(Category category) => switch (category) {
    Category.food => Icons.ramen_dining_outlined,
    Category.transport => Icons.directions_bus_outlined,
    Category.data => Icons.signal_cellular_alt,
    Category.bills => Icons.bolt_outlined,
    Category.fun => Icons.star_outline,
    Category.other => Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!.category(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconFor(category), color: colors.foreground, size: 22),
    );
  }
}
