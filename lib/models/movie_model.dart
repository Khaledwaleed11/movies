import 'package:hive/hive.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 0)
class MovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String overview;

  @HiveField(3)
  final String posterPath;

  @HiveField(4)
  final String backdropPath;

  @HiveField(5)
  final String releaseDate;

  @HiveField(6)
  final double voteAverage;

  @HiveField(7)
  final int voteCount;

  @HiveField(8)
  final double popularity;

  @HiveField(9)
  final bool adult;

  @HiveField(10)
  final String originalLanguage;

   MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.popularity,
    required this.adult,
    required this.originalLanguage,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      posterPath: json['poster_path']?.toString() ?? '',
      backdropPath: json['backdrop_path']?.toString() ?? '',
      releaseDate: json['release_date']?.toString() ?? '',
      voteAverage: _parseDouble(json['vote_average']),
      voteCount: _parseInt(json['vote_count']),
      popularity: _parseDouble(json['popularity']),
      adult: json['adult'] == true,
      originalLanguage: json['original_language']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'popularity': popularity,
      'adult': adult,
      'original_language': originalLanguage,
    };
  }

  MovieModel copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    int? voteCount,
    double? popularity,
    bool? adult,
    String? originalLanguage,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
      adult: adult ?? this.adult,
      originalLanguage: originalLanguage ?? this.originalLanguage,
    );
  }

  bool get hasPoster => posterPath.isNotEmpty;

  bool get hasBackdrop => backdropPath.isNotEmpty;

  String get fullPosterUrl {
    if (posterPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';

  }

  String get fullBackdropUrl {
    if (backdropPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w1280$backdropPath';

  }

  String get formattedReleaseDate {
    if (releaseDate.isEmpty) {
      return 'غير محدد';
    }

    final parts = releaseDate.split('-');

    if (parts.length == 3) {
    return '${parts[2]}/${parts[1]}/${parts[0]}';
    }

    return releaseDate;

  }

  String get formattedRating {
    return voteAverage.toStringAsFixed(1);
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;

  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
    return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;

  }
}
