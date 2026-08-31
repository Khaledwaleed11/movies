import 'package:flutter/material.dart';

class LoadingMovieCard extends StatefulWidget {
  final double width;
  final double posterHeight;

  const LoadingMovieCard({
    super.key,
    this.width = 140,
    this.posterHeight = 205,
  });

  @override
  State<LoadingMovieCard> createState() => _LoadingMovieCardState();
}

class _LoadingMovieCardState extends State<LoadingMovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: widget.width,
                height: widget.posterHeight,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(
                    alpha: 0.55 + (_controller.value * 0.20),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 9),
              Container(
                width: widget.width * 0.85,
                height: 13,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: widget.width * 0.55,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}