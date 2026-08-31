import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              height: 1.55,
              color: colors.onSurfaceVariant,
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 17),
            FilledButton(
              onPressed: onButtonPressed,
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}