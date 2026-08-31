import 'package:hive/hive.dart';

import '../models/movie_details_model.dart';

class MovieDetailsAdapter extends TypeAdapter<MovieDetailsModel> {
  @override
  final int typeId = 1;

  @override
  MovieDetailsModel read(BinaryReader reader) {
    final fields = reader.readMap();

    return MovieDetailsModel(
      id: fields[0] as int,
      title: fields[1] as String,
      overview: fields[2] as String,
      posterPath: fields[3] as String,
      backdropPath: fields[4] as String,
      voteAverage: (fields[5] as num).toDouble(),
      voteCount: fields[6] as int,
      releaseDate: fields[7] as String,
      runtime: fields[8] as int,
      originalLanguage: fields[9] as String,
      genres: List<String>.from(fields[10] as List),
      cast: (fields[11] as List)
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
      )
          .toList(),
      trailerKey: fields[12] as String?,
    );
  }

  @override
  void write(
      BinaryWriter writer,
      MovieDetailsModel obj,
      ) {
    writer.writeMap({
      0: obj.id,
      1: obj.title,
      2: obj.overview,
      3: obj.posterPath,
      4: obj.backdropPath,
      5: obj.voteAverage,
      6: obj.voteCount,
      7: obj.releaseDate,
      8: obj.runtime,
      9: obj.originalLanguage,
      10: obj.genres,
      11: obj.cast,
      12: obj.trailerKey,
    });
  }
}