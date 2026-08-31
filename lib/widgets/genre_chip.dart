import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primary
          : colors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: selected
                  ? colors.onPrimary
                  : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}