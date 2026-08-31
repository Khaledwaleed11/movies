import 'dart:async';

import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/movie_service.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_movie_card.dart';
import '../widgets/movie_hero.dart';
import '../widgets/movie_horizontal_list.dart';
import '../widgets/section_header.dart';
import 'movie_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();

  late final PageController _heroController;
  late final AnimationController _entranceController;
  late final AnimationController _headerController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _headerScaleAnimation;

  List<MovieModel> _trendingMovies = [];
  List<MovieModel> _popularMovies = [];
  List<MovieModel> _topRatedMovies = [];
  List<MovieModel> _upcomingMovies = [];

  Timer? _heroTimer;

  int _currentHeroIndex = 0;

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _heroController = PageController(viewportFraction: 0.91);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _headerScaleAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    _headerController.forward();

    _loadMovies();
  }

  Future<void> _loadMovies() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final results = await Future.wait([
        _movieService.getTrendingMovies(),
        _movieService.getPopularMovies(),
        _movieService.getTopRatedMovies(),
        _movieService.getUpcomingMovies(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _trendingMovies = results[0];
        _popularMovies = results[1];
        _topRatedMovies = results[2];
        _upcomingMovies = results[3];
        _isLoading = false;
      });

      _entranceController.forward(from: 0);
      _startHeroAutoPlay();
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _startHeroAutoPlay() {
    _heroTimer?.cancel();

    if (_trendingMovies.length < 2) {
      return;
    }

    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_heroController.hasClients) {
        return;
      }

      final nextIndex = (_currentHeroIndex + 1) % _trendingMovies.length;

      _heroController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openDetails(MovieModel movie) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) {
          return MovieDetailsScreen(movie: movie);
        },
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

  void _openSearch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) {
          return const SearchScreen();
        },
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    _entranceController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: _hasError
            ? ErrorState(
                title: 'تعذر تحميل الأفلام',
                message: 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى.',
                onRetry: _loadMovies,
              )
            : RefreshIndicator(
                color: colors.primary,
                backgroundColor: colors.surface,
                strokeWidth: 2.5,
                onRefresh: _loadMovies,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: ScaleTransition(
                          scale: _headerScaleAnimation,
                          child: _buildHeader(colors),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutCubic,
                        child: _isLoading
                            ? _buildLoading(colors)
                            : FadeTransition(
                                key: const ValueKey('content'),
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: _buildContent(colors),
                                ),
                              ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 35)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.movie_creation_rounded,
              color: colors.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CINEMA',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'اكتشف عالم الأفلام',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.65),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: _openSearch,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: colors.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildHeroSection(colors),
        const SizedBox(height: 30),
        _buildMovieSection(
          colors,
          title: 'الأكثر مشاهدة',
          subtitle: 'الأفلام الرائجة حاليًا',
          movies: _popularMovies,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: 32),
        _buildMovieSection(
          colors,
          title: 'الأعلى تقييمًا',
          subtitle: 'أفلام تستحق المشاهدة',
          movies: _topRatedMovies,
          icon: Icons.star_rounded,
        ),
        const SizedBox(height: 32),
        _buildMovieSection(
          colors,
          title: 'قريبًا',
          subtitle: 'أحدث الإصدارات القادمة',
          movies: _upcomingMovies,
          icon: Icons.upcoming_rounded,
        ),
      ],
    );
  }

  Widget _buildHeroSection(ColorScheme colors) {
    if (_trendingMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 430,
          child: PageView.builder(
            controller: _heroController,
            itemCount: _trendingMovies.length,
            onPageChanged: (index) {
              if (!mounted) {
                return;
              }

              setState(() {
                _currentHeroIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final movie = _trendingMovies[index];

              return AnimatedBuilder(
                animation: _heroController,
                builder: (context, child) {
                  double scale = 1.0;

                  if (_heroController.hasClients) {
                    final page =
                        _heroController.page ?? _currentHeroIndex.toDouble();

                    final distance = (page - index).abs();

                    scale = (1 - distance * 0.055).clamp(0.91, 1.0);
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: child,
                    ),
                  );
                },
                child: MovieHero(
                  movie: movie,
                  onTap: () => _openDetails(movie),
                  onPlay: () => _openDetails(movie),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_trendingMovies.length.clamp(0, 8), (index) {
            final selected = index == _currentHeroIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 28 : 7,
              height: 6,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(colors: [colors.primary, colors.secondary])
                    : null,
                color: selected ? null : colors.outlineVariant,
                borderRadius: BorderRadius.circular(30),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMovieSection(
    ColorScheme colors, {
    required String title,
    required String subtitle,
    required List<MovieModel> movies,
    required IconData icon,
  }) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(title: title, subtitle: subtitle, icon: icon),
        ),
        const SizedBox(height: 14),
        MovieHorizontalList(
          movies: movies.take(10).toList(),
          onMovieTap: _openDetails,
        ),
      ],
    );
  }

  Widget _buildLoading(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 430,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 280,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                LoadingMovieCard(),
                SizedBox(width: 14),
                LoadingMovieCard(),
                SizedBox(width: 14),
                LoadingMovieCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
