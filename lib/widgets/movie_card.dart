import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import 'movie_rating.dart';

class MovieCard extends StatefulWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final double width;
  final double posterHeight;
  final bool showRating;
  final bool showPlayButton;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width = 140,
    this.posterHeight = 205,
    this.showRating = true,
    this.showPlayButton = true,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final movie = widget.movie;

    return SizedBox(
      width: widget.width,
      height: widget.posterHeight + 60,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: widget.posterHeight,
                width: widget.width,
                child: Hero(
                  tag: 'movie_poster_${movie.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: movie.hasPoster
                              ? Image.network(
                            movie.fullPosterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _buildPlaceholder(colors);
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _buildLoading(colors);
                            },
                          )
                              : _buildPlaceholder(colors),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.55),
                                ],
                                stops: const [0.5, 1],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        if (widget.showRating)
                          Positioned(
                            top: 9,
                            left: 9,
                            child: MovieRating(
                              rating: movie.voteAverage,
                              compact: true,
                            ),
                          ),
                        if (widget.showPlayButton)
                          Positioned(
                            right: 9,
                            bottom: 9,
                            child: Container(
                              width: 31,
                              height: 31,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 19,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                movie.title.isEmpty ? 'بدون عنوان' : movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              if (movie.releaseDate.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  movie.releaseDate.length >= 4
                      ? movie.releaseDate.substring(0, 4)
                      : movie.releaseDate,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: 38,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}