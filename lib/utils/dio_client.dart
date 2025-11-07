import 'package:dio/dio.dart';

class DioClient {
  //https://api.openweathermap.org/data/2.5/weather?q=Tehran&appid=3956f080743e9559357c046dd5f37415
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String OPEN_WEATHER_MAP_API_KEY =
      '3956f080743e9559357c046dd5f37415';
  static const Duration timeout = Duration(seconds: 30);

  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => print('[DIO] $log'),
      ),
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Handle common errors
          if (error.response?.statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Weather data not found for the specified location',
                type: error.type,
              ),
            );
          }
          return handler.next(error);
        },
      ),
    ]);
  }

  Dio get dio => _dio;

  // Generic GET method
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters
          ?..addAll({'appid': OPEN_WEATHER_MAP_API_KEY}),
        options: options,
      );
      return response;
    } on DioException catch (e) {
      // Re-throw with more context
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Generic POST method (for future use)
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters
          ?..addAll({'appid': OPEN_WEATHER_MAP_API_KEY}),
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.statusMessage ?? 'Unknown error';
        return Exception('HTTP $statusCode: $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection');

      case DioExceptionType.unknown:
      default:
        return Exception('An unexpected error occurred: ${error.message}');
    }
  }

  void dispose() {
    _dio.close();
  }
}
