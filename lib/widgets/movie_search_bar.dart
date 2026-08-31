import 'package:flutter/material.dart';

class MovieSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onFilterTap;
  final String hintText;

  const MovieSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.hintText = 'ابحث عن فيلم...',
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: (_) => onSubmitted?.call(),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                hintTextDirection: TextDirection.rtl,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged?.call('');
              },
              icon: Icon(
                Icons.close_rounded,
                size: 19,
                color: colors.onSurfaceVariant,
              ),
            ),
          if (onFilterTap != null)
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.tune_rounded,
                size: 20,
                color: colors.primary,
              ),
            ),
          const SizedBox(width: 3),
        ],
      ),
    );
  }
}