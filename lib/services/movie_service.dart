import '../api/movie_api_service.dart';
import '../models/movie_model.dart';

class MovieService {
  final MovieApiService _apiService = MovieApiService();

  Future<List<MovieModel>> getPopularMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    final data = await _apiService.getPopularMovies(
      page: page,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<List<MovieModel>> getTrendingMovies({
    String timeWindow = 'week',
    String language = 'en-US',
  }) async {
    final data = await _apiService.getTrendingMovies(
      timeWindow: timeWindow,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<List<MovieModel>> getTopRatedMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    final data = await _apiService.getTopRatedMovies(
      page: page,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<List<MovieModel>> getUpcomingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    final data = await _apiService.getUpcomingMovies(
      page: page,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<List<MovieModel>> getNowPlayingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    final data = await _apiService.getNowPlayingMovies(
      page: page,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<List<MovieModel>> searchMovies({
    required String query,
    int page = 1,
    String language = 'en-US',
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final data = await _apiService.searchMovies(
      query: query.trim(),
      page: page,
      language: language,
    );

    return _parseMovies(data);
  }

  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String language = 'en-US',
  }) async {
    return _apiService.getMovieDetails(movieId, language: language);
  }

  Future<MovieModel?> getMovieById(
    int movieId, {
    String language = 'en-US',
  }) async {
    final data = await getMovieDetails(movieId, language: language);

    if (data.isEmpty) {
      return null;
    }

    return MovieModel.fromJson(data);
  }

  List<MovieModel> _parseMovies(Map<String, dynamic> data) {
    final results = data['results'];

    if (results is! List) {
      return [];
    }

    return results
        .whereType<Map>()
        .map((item) => MovieModel.fromJson(Map<String, dynamic>.from(item)))
        .where((movie) => movie.id != 0)
        .toList();
  }
}
