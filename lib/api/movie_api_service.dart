import 'package:dio/dio.dart';

class MovieApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  static const String _apiKey = '5e9bc379b19d8a2e2a5db7b82c377e78';

  late final Dio _dio;

  MovieApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
        queryParameters: {
          'api_key': _apiKey,
        },
      ),
    );
  }
  Future<Map<String, dynamic>> getPopularMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'language': language, 'page': page},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load popular movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> getTrendingMovies({
    String timeWindow = 'week',
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/trending/movie/$timeWindow',
        queryParameters: {'language': language},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load trending movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> getTopRatedMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {'language': language, 'page': page},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load top rated movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> getUpcomingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/upcoming',
        queryParameters: {'language': language, 'page': page},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load upcoming movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> getNowPlayingMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {'language': language, 'page': page},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load now playing movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> searchMovies({
    required String query,
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {
          'query': query,
          'language': language,
          'page': page,
          'include_adult': false,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to search movies.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String language = 'en-US',
  }) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {
          'language': language,
          'append_to_response': 'videos,similar,credits',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      throw Exception('Failed to load movie details.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Something went wrong: $e');
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout.';

      case DioExceptionType.sendTimeout:
        return 'Request send timeout.';

      case DioExceptionType.receiveTimeout:
        return 'Response timeout.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        switch (statusCode) {
          case 401:
            return 'Invalid or unauthorized API key.';

          case 404:
            return 'Requested resource was not found.';

          case 429:
            return 'Too many requests. Please try again later.';

          case 500:
            return 'TMDB server error.';

          default:
            return 'Server error: ${statusCode ?? 'unknown'}';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'No internet connection.';

      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate.';

      case DioExceptionType.unknown:
        return 'An unexpected network error occurred.';
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
