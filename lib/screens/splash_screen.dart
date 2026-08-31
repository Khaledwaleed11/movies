import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _shutterController;
  late final AnimationController _textController;
  late final AnimationController _stripController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _shutterSpin;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // LOGO ANIMATION
    // ============================================================

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
    );

    // ============================================================
    // SHUTTER ANIMATION
    // ============================================================

    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _shutterSpin = Tween<double>(begin: 0, end: 1).animate(_shutterController);

    // ============================================================
    // TEXT ANIMATION
    // ============================================================

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    // ============================================================
    // FILM STRIP ANIMATION
    // ============================================================

    _stripController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    _run();
  }

  // ==============================================================
  // SPLASH FLOW
  // ==============================================================

  Future<void> _run() async {
    await _logoController.forward();

    if (!mounted) return;

    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, __) {
          return const MainScreen();
        },
        transitionsBuilder: (_, animation, __, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.98,
                end: 1,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shutterController.dispose();
    _textController.dispose();
    _stripController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    // ============================================================
    // THEME AWARE COLORS
    // ============================================================

    final backgroundColor = colors.surfaceContainerLowest;

    final primaryTextColor = colors.onSurface;

    final secondaryTextColor = colors.onSurfaceVariant;

    final filmStripColor = colors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ========================================================
          // TOP FILM STRIP
          // ========================================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FilmStrip(
              controller: _stripController,
              color: filmStripColor,
            ),
          ),

          // ========================================================
          // BOTTOM FILM STRIP
          // ========================================================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _FilmStrip(
              controller: _stripController,
              color: filmStripColor,
              reverse: true,
            ),
          ),

          // ========================================================
          // CINEMATIC VIGNETTE
          // ========================================================
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [
                    Colors.transparent,
                    backgroundColor.withValues(alpha: isDark ? 0.55 : 0.25),
                    backgroundColor,
                  ],
                  stops: const [0.30, 0.75, 1.0],
                ),
              ),
            ),
          ),

          // ========================================================
          // MAIN CONTENT
          // ========================================================
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --------------------------------------------------
                // LOGO
                // --------------------------------------------------
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoController,
                    _shutterController,
                  ]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: Transform.scale(
                        scale: 0.6 + (_logoScale.value * 0.4),
                        child: child,
                      ),
                    );
                  },
                  child: _buildLogo(colors),
                ),

                const SizedBox(height: 26),

                // --------------------------------------------------
                // TEXT
                // --------------------------------------------------
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        // CINEMA GRADIENT TEXT
                        ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [colors.primary, colors.secondary],
                            ).createShader(rect);
                          },
                          child: Text(
                            'CINEMA',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: primaryTextColor,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'كل الأفلام. في مكان واحد.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // LOADING BAR
          // ========================================================
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: colors.onSurface.withValues(
                        alpha: isDark ? 0.08 : 0.10,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // LOGO
  // ==============================================================

  Widget _buildLogo(ColorScheme colors) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // --------------------------------------------------------
          // SHUTTER
          // --------------------------------------------------------
          RotationTransition(
            turns: _shutterSpin,
            child: CustomPaint(
              size: const Size(108, 108),
              painter: _ShutterPainter(color: colors.primary),
            ),
          ),

          // --------------------------------------------------------
          // CENTER BUTTON
          // --------------------------------------------------------
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: colors.onPrimary,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SHUTTER PAINTER
// ==================================================================

class _ShutterPainter extends CustomPainter {
  final Color color;

  const _ShutterPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const bladeCount = 6;

    for (int i = 0; i < bladeCount; i++) {
      final angle = (i * 2 * math.pi) / bladeCount;

      final start = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );

      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShutterPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// ==================================================================
// FILM STRIP
// ==================================================================

class _FilmStrip extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final bool reverse;

  const _FilmStrip({
    required this.controller,
    required this.color,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final progress = reverse ? 1 - controller.value : controller.value;

          return ClipRect(
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Transform.translate(
                offset: Offset(-progress * 400, 0),
                child: Row(
                  children: List.generate(60, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: color.withValues(alpha: 0.10),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
