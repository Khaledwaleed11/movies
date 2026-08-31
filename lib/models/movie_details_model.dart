import 'package:hive/hive.dart';

class MovieDetailsModel extends HiveObject {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final int runtime;
  final String originalLanguage;
  final List<String> genres;
  final List<Map<String, dynamic>> cast;
  final String? trailerKey;

  MovieDetailsModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.runtime,
    required this.originalLanguage,
    required this.genres,
    required this.cast,
    this.trailerKey,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    final genresData = json['genres'];

    final genres = genresData is List
        ? genresData
        .whereType<Map>()
        .map((genre) => genre['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList()
        : <String>[];

    final credits = json['credits'];

    final castData = credits is Map ? credits['cast'] : null;

    final cast = castData is List
        ? castData
        .whereType<Map>()
        .take(10)
        .map(
          (person) => <String, dynamic>{
        'id': person['id'],
        'name': person['name']?.toString() ?? '',
        'character': person['character']?.toString() ?? '',
        'profile_path': person['profile_path']?.toString(),
      },
    )
        .toList()
        : <Map<String, dynamic>>[];

    String? trailerKey;

    final videos = json['videos'];

    if (videos is Map) {
      final results = videos['results'];

      if (results is List) {
        // الأولوية للتريلر الرسمي
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
            trailerKey = key;
            break;
          }
        }

        // لو مفيش رسمي، هات أي Trailer من YouTube
        if (trailerKey == null) {
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
              trailerKey = key;
              break;
            }
          }
        }
      }
    }

    return MovieDetailsModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      posterPath: json['poster_path']?.toString() ?? '',
      backdropPath: json['backdrop_path']?.toString() ?? '',
      voteAverage: json['vote_average'] is num
          ? (json['vote_average'] as num).toDouble()
          : 0.0,
      voteCount: json['vote_count'] is num
          ? (json['vote_count'] as num).toInt()
          : 0,
      releaseDate: json['release_date']?.toString() ?? '',
      runtime: json['runtime'] is num
          ? (json['runtime'] as num).toInt()
          : 0,
      originalLanguage:
      json['original_language']?.toString() ?? '',
      genres: genres,
      cast: cast,
      trailerKey: trailerKey,
    );
  }

  MovieDetailsModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    int? voteCount,
    String? releaseDate,
    int? runtime,
    String? originalLanguage,
    List<String>? genres,
    List<Map<String, dynamic>>? cast,
    String? trailerKey,
  }) {
    return MovieDetailsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      releaseDate: releaseDate ?? this.releaseDate,
      runtime: runtime ?? this.runtime,
      originalLanguage:
      originalLanguage ?? this.originalLanguage,
      genres: genres ?? this.genres,
      cast: cast ?? this.cast,
      trailerKey: trailerKey ?? this.trailerKey,
    );
  }
}