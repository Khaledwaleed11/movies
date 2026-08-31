import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/movie_details_model.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';
import '../widgets/error_state.dart';
import '../widgets/genre_chip.dart';
import '../widgets/movie_horizontal_list.dart';
import '../widgets/movie_info.dart';
import '../widgets/movie_rating.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with TickerProviderStateMixin {
  final MovieService _movieService = MovieService();

  Map<String, dynamic>? _details;
  List<MovieModel> _similarMovies = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _isFavorite = false;

  late final AnimationController _contentController;
  late final AnimationController _favoriteController;
  late final AnimationController _backdropController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _favoriteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.8,
      upperBound: 1.15,
    );

    _backdropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 1.04, end: 1).animate(
      CurvedAnimation(parent: _backdropController, curve: Curves.easeOutCubic),
    );

    _checkFavorite();
    _loadDetails();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _favoriteController.dispose();
    _backdropController.dispose();
    super.dispose();
  }

  void _checkFavorite() {
    final box = Hive.box<MovieDetailsModel>('movieDetails');
    _isFavorite = box.containsKey(widget.movie.id);
  }

  Future<void> _toggleFavorite() async {
    final box = Hive.box<MovieDetailsModel>('movieDetails');

    if (box.containsKey(widget.movie.id)) {
      await box.delete(widget.movie.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _isFavorite = false;
      });

      _favoriteController.forward(from: 0.8).then((_) {
        if (mounted) {
          _favoriteController.reverse();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('تم حذف الفيلم من المفضلة'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(milliseconds: 1300),
        ),
      );

      return;
    }

    MovieDetailsModel movieToSave;

    if (_details != null) {
      movieToSave = MovieDetailsModel.fromJson(_details!);
    } else {
      movieToSave = MovieDetailsModel(
        id: widget.movie.id,
        title: widget.movie.title,
        overview: widget.movie.overview,
        posterPath: widget.movie.posterPath,
        backdropPath: widget.movie.backdropPath,
        voteAverage: widget.movie.voteAverage,
        voteCount: widget.movie.voteCount,
        releaseDate: widget.movie.releaseDate,
        runtime: 0,
        originalLanguage: widget.movie.originalLanguage,
        genres: [],
        cast: [],
        trailerKey: null,
      );
    }

    await box.put(movieToSave.id, movieToSave);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = true;
    });

    _favoriteController.forward(from: 0.8).then((_) {
      if (mounted) {
        _favoriteController.reverse();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text('تمت إضافة الفيلم للمفضلة ❤️'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(milliseconds: 1300),
      ),
    );
  }

  Future<void> _loadDetails() async {
    try {
      final data = await _movieService.getMovieDetails(widget.movie.id);

      if (!mounted) {
        return;
      }

      final similarData = data['similar'];

      List<MovieModel> similar = [];

      if (similarData is Map) {
        final results = similarData['results'];

        if (results is List) {
          similar = results
              .whereType<Map>()
              .map(
                (item) => MovieModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((movie) => movie.id != 0)
              .toList();
        }
      }

      setState(() {
        _details = data;
        _similarMovies = similar;
        _isLoading = false;
      });

      _backdropController.forward();
      _contentController.forward();
    } catch (e) {
      debugPrint('MOVIE DETAILS ERROR: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _formatRuntime(dynamic runtime) {
    if (runtime is! num || runtime <= 0) {
      return 'غير محدد';
    }

    final totalMinutes = runtime.toInt();

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '$minutes دقيقة';
    }

    return '$hours س $minutes د';
  }

  List<String> _getGenres() {
    final genres = _details?['genres'];

    if (genres is! List) {
      return [];
    }

    return genres
        .whereType<Map>()
        .map((genre) => genre['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> _getCast() {
    final credits = _details?['credits'];

    if (credits is! Map) {
      return [];
    }

    final cast = credits['cast'];

    if (cast is! List) {
      return [];
    }

    return cast
        .whereType<Map>()
        .take(10)
        .map((person) => Map<String, dynamic>.from(person))
        .toList();
  }

  String? _getTrailerKey() {
    final videos = _details?['videos'];

    if (videos is! Map) {
      return null;
    }

    final results = videos['results'];

    if (results is! List) {
      return null;
    }

    for (final item in results) {
      if (item is! Map) {
        continue;
      }

      final site = item['site']?.toString();
      final type = item['type']?.toString();
      final official = item['official'] == true;
      final key = item['key']?.toString();

      if (site == 'YouTube' &&
          type == 'Trailer' &&
          official &&
          key != null &&
          key.isNotEmpty) {
        return key;
      }
    }

    for (final item in results) {
      if (item is! Map) {
        continue;
      }

      final site = item['site']?.toString();
      final type = item['type']?.toString();
      final key = item['key']?.toString();

      if (site == 'YouTube' &&
          type == 'Trailer' &&
          key != null &&
          key.isNotEmpty) {
        return key;
      }
    }

    return null;
  }

  Future<void> _openTrailer(String trailerKey) async {
    final youtubeUri = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');

    try {
      bool opened = await launchUrl(
        youtubeUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        opened = await launchUrl(youtubeUri, mode: LaunchMode.platformDefault);
      }

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح YouTube على الجهاز'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح إعلان الفيلم'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: _hasError
          ? SafeArea(
              child: ErrorState(
                title: 'تعذر تحميل الفيلم',
                message: 'حصلت مشكلة أثناء تحميل تفاصيل الفيلم.',
                onRetry: _loadDetails,
              ),
            )
          : _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'جاري تحميل التفاصيل...',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 380,
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: colors.surface,
                  surfaceTintColor: Colors.transparent,
                  leading: _buildBackButton(colors),
                  actions: [
                    _buildFavoriteButton(colors),
                    const SizedBox(width: 10),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: AnimatedBuilder(
                      animation: _backdropController,
                      builder: (_, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: _buildBackdrop(colors),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildContent(colors),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBackButton(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          customBorder: const CircleBorder(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(ColorScheme colors) {
    return AnimatedBuilder(
      animation: _favoriteController,
      builder: (_, child) {
        return Transform.scale(scale: _favoriteController.value, child: child);
      },
      child: Material(
        color: Colors.black.withValues(alpha: 0.42),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _toggleFavorite,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(_isFavorite),
                color: _isFavorite ? Colors.redAccent : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop(ColorScheme colors) {
    final movie = _details == null
        ? widget.movie
        : MovieModel.fromJson(_details!);

    final backdropContent = movie.hasBackdrop
        ? Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                movie.fullBackdropUrl,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  return _buildBackdropFallback(colors);
                },
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.48, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colors.surfaceContainerLowest.withValues(alpha: 0.96),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        : _buildBackdropFallback(colors);

    // Hero animation: matches the tag used on MovieHero's backdrop image
    // on the home screen, so the transition into this screen is seamless.
    return Hero(tag: 'movie_backdrop_${movie.id}', child: backdropContent);
  }

  Widget _buildBackdropFallback(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerHighest],
        ),
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.movie_rounded,
            size: 50,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    final movie = _details == null
        ? widget.movie
        : MovieModel.fromJson(_details!);

    final genres = _getGenres();
    final cast = _getCast();
    final trailerKey = _getTrailerKey();

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      transform: Matrix4.translationValues(0, -20, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title only — the vote-average badge that used to sit here was
            // removed because MovieRating just below already shows the same
            // rating, and showing it twice competed for attention.
            Text(
              movie.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 26,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                MovieRating(rating: movie.voteAverage),
                const SizedBox(width: 10),
                if (movie.releaseDate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      movie.releaseDate.length >= 4
                          ? movie.releaseDate.substring(0, 4)
                          : movie.releaseDate,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            if (genres.isNotEmpty) ...[
              const SizedBox(height: 17),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: genres.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 7);
                  },
                  itemBuilder: (_, index) {
                    return GenreChip(label: genres[index]);
                  },
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: MovieInfo(
                    title: 'التقييم',
                    value: '${movie.voteAverage.toStringAsFixed(1)} / 10',
                    icon: Icons.star_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MovieInfo(
                    title: 'التصويت',
                    value: '${movie.voteCount}',
                    icon: Icons.people_alt_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: MovieInfo(
                    title: 'المدة',
                    value: _formatRuntime(_details?['runtime']),
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MovieInfo(
                    title: 'اللغة',
                    value: movie.originalLanguage.toUpperCase(),
                    icon: Icons.language_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle(colors, 'عن الفيلم', Icons.info_outline_rounded),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                movie.overview.isEmpty
                    ? 'لا توجد نبذة متاحة عن هذا الفيلم.'
                    : movie.overview,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.75,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (trailerKey != null) ...[
              const SizedBox(height: 22),
              _buildTrailerButton(colors, trailerKey),
            ],
            if (cast.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionTitle(colors, 'طاقم التمثيل', Icons.groups_rounded),
              const SizedBox(height: 14),
              _buildCastList(cast, colors),
            ],
            if (_similarMovies.isNotEmpty) ...[
              const SizedBox(height: 34),
              _buildSectionTitle(
                colors,
                'أفلام مشابهة',
                Icons.auto_awesome_rounded,
              ),
              const SizedBox(height: 12),
              MovieHorizontalList(
                movies: _similarMovies.take(10).toList(),
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 450),
                      pageBuilder: (_, animation, __) {
                        return MovieDetailsScreen(movie: movie);
                      },
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ColorScheme colors, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailerButton(ColorScheme colors, String trailerKey) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: () {
          _openTrailer(trailerKey);
        },
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 8,
          shadowColor: colors.primary.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: colors.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'مشاهدة التريلر',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastList(List<Map<String, dynamic>> cast, ColorScheme colors) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: cast.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 13);
        },
        itemBuilder: (_, index) {
          final person = cast[index];

          final name = person['name']?.toString() ?? '';
          final character = person['character']?.toString() ?? '';
          final profilePath = person['profile_path']?.toString();

          return SizedBox(
            width: 88,
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 98,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: profilePath == null || profilePath.isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          size: 32,
                          color: colors.onSurfaceVariant,
                        )
                      : Image.network(
                          'https://image.tmdb.org/t/p/w185$profilePath',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: colors.onSurfaceVariant,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  character,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
