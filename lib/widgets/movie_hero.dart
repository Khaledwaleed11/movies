import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import 'movie_rating.dart';

class MovieHero extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const MovieHero({
    super.key,
    required this.movie,
    this.onTap,
    this.onPlay,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 430,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colors.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie_backdrop_${movie.id}',
              child: _buildBackground(colors),
            ),

            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.38, 1.0],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (movie.voteAverage > 0)
                        MovieRating(rating: movie.voteAverage),
                      const Spacer(),
                      if (onFavorite != null) _buildFavoriteButton(),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 27,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 12,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      if (movie.releaseDate.isNotEmpty)
                        Text(
                          movie.releaseDate.length >= 4
                              ? movie.releaseDate.substring(0, 4)
                              : movie.releaseDate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      if (movie.originalLanguage.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildDot(),
                        const SizedBox(width: 8),
                        Text(
                          movie.originalLanguage.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (movie.overview.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      movie.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.45,
                        color: Colors.white70,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      if (onPlay != null)
                        FilledButton.icon(
                          onPressed: onPlay,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'التفاصيل',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onFavorite,
        customBorder: const CircleBorder(),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              color: isFavorite ? Colors.redAccent : Colors.white,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(ColorScheme colors) {
    final url = movie.hasBackdrop
        ? movie.fullBackdropUrl
        : (movie.hasPoster ? movie.fullPosterUrl : null);

    if (url == null) {
      return _buildFallback(colors);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallback(colors),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _buildFallback(colors, showLoader: true);
      },
    );
  }

  Widget _buildFallback(ColorScheme colors, {bool showLoader = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
        ),
      ),
      child: Center(
        child: showLoader
            ? SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colors.onSurfaceVariant,
          ),
        )
            : Icon(Icons.movie_rounded, size: 65, color: colors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}