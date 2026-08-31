import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import 'movie_card.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<MovieModel> movies;
  final Function(MovieModel movie)? onMovieTap;
  final double cardWidth;
  final double posterHeight;
  final EdgeInsetsGeometry padding;
  final bool showRating;
  final bool showPlayButton;

  const MovieHorizontalList({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.cardWidth = 140,
    this.posterHeight = 205,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.showRating = true,
    this.showPlayButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: posterHeight + 65,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = movies[index];

          return MovieCard(
            movie: movie,
            width: cardWidth,
            posterHeight: posterHeight,
            showRating: showRating,
            showPlayButton: showPlayButton,
            onTap: onMovieTap == null ? null : () => onMovieTap!(movie),
          );
        },
      ),
    );
  }
}
