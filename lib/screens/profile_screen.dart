import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'حسابي',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 45,
                color: colors.onPrimary,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'مرحبًا بك 🎬',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'استمتع باكتشاف أفلامك المفضلة',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}