import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/movie_model.dart';
import '../../models/movie_details_model.dart';
import '../../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  MovieModel _toMovieModel(MovieDetailsModel movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseDate: movie.releaseDate,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      popularity: 0,
      adult: false,
      originalLanguage: movie.originalLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: ValueListenableBuilder<Box<MovieDetailsModel>>(
          valueListenable: Hive.box<MovieDetailsModel>(
            'movieDetails',
          ).listenable(),
          builder: (context, box, _) {
            final count = box.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'المفضلة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                if (count > 0)
                  Text(
                    '$count فيلم محفوظ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      body: ValueListenableBuilder<Box<MovieDetailsModel>>(
        valueListenable: Hive.box<MovieDetailsModel>(
          'movieDetails',
        ).listenable(),
        builder: (context, box, _) {
          final movies = box.values.toList();

          if (movies.isEmpty) {
            return _buildEmptyState(context);
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  // MovieCard has poster + title + year.
                  childAspectRatio: 0.57,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final detailsMovie = movies[index];
                  final movie = _toMovieModel(detailsMovie);

                  return _StaggeredGridItem(
                    index: index,
                    child: Dismissible(
                      key: ValueKey(detailsMovie.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        return await _showDeleteDialog(
                          context,
                          detailsMovie.title,
                        );
                      },
                      onDismissed: (_) async {
                        await box.delete(detailsMovie.id);

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حذف الفيلم من المفضلة'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      background: _buildDismissBackground(colors, context),
                      child: MovieCard(
                        movie: movie,
                        width: double.infinity,
                        posterHeight: 205,
                        showRating: true,
                        showPlayButton: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Dismiss-reveal panel behind the card. Aligned using the ambient
  /// [Directionality] (via [AlignmentDirectional]) instead of a hard-coded
  /// side, so it lines up correctly with the swipe direction in this
  /// right-to-left (Arabic) app instead of assuming a left-to-right layout.
  Widget _buildDismissBackground(ColorScheme colors, BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.only(start: 20),
      decoration: BoxDecoration(
        color: colors.error,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.delete_rounded, color: colors.onError, size: 28),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0, 1),
              child: Transform.scale(scale: 0.85 + (value * 0.15), child: child),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.18),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 50,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'مفيش أفلام في المفضلة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'لما تعجبك أي حاجة، دوس على ❤️ وهتلاقي الفيلم هنا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, String movieTitle) {
    final colors = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'حذف الفيلم؟',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text('هل تريد حذف "$movieTitle" من المفضلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}

/// Wraps a grid item with a fade + rise-in animation whose start time is
/// offset by [index], so cards appear in a quick cascading wave rather
/// than all popping in at once.
class _StaggeredGridItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredGridItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    // Cap the delay so items far down a long list don't wait too long.
    final delay = (index % 10) * 45;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}