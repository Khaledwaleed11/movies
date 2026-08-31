import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/movie_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_movie_card.dart';
import '../widgets/movie_card.dart';
import '../widgets/movie_search_bar.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<MovieModel> _movies = [];

  bool _isLoading = false;
  bool _hasError = false;
  bool _hasSearched = false;

  int _page = 1;
  bool _isLoadingMore = false;
  // Once a page comes back empty (or short of a full page), there's no
  // point requesting further pages — stops redundant network calls when
  // the user keeps scrolling at the end of the results.
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    final query = value.trim();

    if (query.isEmpty) {
      setState(() {
        _movies = [];
        _hasSearched = false;
        _hasError = false;
        _isLoading = false;
        _page = 1;
        _hasMore = true;
      });

      return;
    }

    _debounce = Timer(const Duration(milliseconds: 550), () {
      _searchMovies(query);
    });
  }

  Future<void> _searchMovies(
      String query, {
        int page = 1,
        bool loadMore = false,
      }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) {
        return;
      }

      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _hasSearched = true;
        _page = page;
        _hasMore = true;
      });
    }

    try {
      final movies = await _movieService.searchMovies(
        query: query,
        page: page,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (loadMore) {
          _movies.addAll(movies);
        } else {
          _movies = movies;
        }

        // A short or empty page means we've reached the end of the results.
        if (movies.isEmpty || movies.length < 20) {
          _hasMore = false;
        }

        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
      });
    }
  }

  void _loadMore() {
    if (_movies.isEmpty ||
        _isLoadingMore ||
        !_hasMore ||
        _searchController.text.trim().isEmpty) {
      return;
    }

    final nextPage = _page + 1;

    setState(() {
      _page = nextPage;
    });

    _searchMovies(
      _searchController.text.trim(),
      page: nextPage,
      loadMore: true,
    );
  }

  void _openDetails(MovieModel movie) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, __) => MovieDetailsScreen(movie: movie),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onControllerChanged);
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text(
          'البحث',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: MovieSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: () {
                final query = _searchController.text.trim();

                if (query.isNotEmpty) {
                  _searchMovies(query);
                }
              },
            ),
          ),
          if (_hasSearched && _movies.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Row(
                children: [
                  Text(
                    '${_movies.length} نتيجة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(colors)),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_hasError) {
      return ErrorState(
        title: 'فشل البحث',
        message: 'حصلت مشكلة أثناء تحميل نتائج البحث.',
        onRetry: () {
          final query = _searchController.text.trim();

          if (query.isNotEmpty) {
            _searchMovies(query);
          }
        },
      );
    }

    if (_isLoading && _movies.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
          childAspectRatio: 0.61,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const LoadingMovieCard(
            width: double.infinity,
            posterHeight: 225,
          );
        },
      );
    }

    if (!_hasSearched) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'ابحث عن فيلم',
        message: 'اكتب اسم فيلم أو كلمة للعثور على أفلامك المفضلة.',
      );
    }

    if (_movies.isEmpty) {
      return const EmptyState(
        icon: Icons.movie_filter_outlined,
        title: 'لم نجد نتائج',
        message: 'جرّب اسم فيلم آخر أو استخدم كلمة بحث مختلفة.',
      );
    }

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 250) {
              _loadMore();
            }

            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 46),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: 0.61,
            ),
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              return _StaggeredItem(
                index: index,
                child: MovieCard(
                  movie: _movies[index],
                  width: double.infinity,
                  posterHeight: 225,
                  showPlayButton: true,
                  onTap: () => _openDetails(_movies[index]),
                ),
              );
            },
          ),
        ),
        // Small pagination indicator that fades in only while a next page
        // is being fetched, so scrolling to the end never feels stalled.
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: _isLoadingMore ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fades and rises a grid item in, offset by [index] so results cascade in
/// a quick wave instead of appearing all at once.
class _StaggeredItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = (index % 10) * 40;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 340 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}