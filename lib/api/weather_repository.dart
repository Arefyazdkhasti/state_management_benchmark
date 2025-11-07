import 'dart:async';

import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/utils/dio_client.dart';

class WeatherRepository {
  final DioClient _dioClient;

  // Simple in-memory cache for the last result
  Weather? _cachedWeather;
  DateTime? _cacheTimestamp;
  static const Duration cacheDuration = Duration(minutes: 5);

  WeatherRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient();

  /// Fetch weather data for a given city or ICAO code
  ///
  /// [location] can be either a city name or ICAO airport code
  /// [useCache] determines whether to use cached data if available
  Future<Weather> getWeather(String location, {bool useCache = true}) async {
    // Check cache first
    if (useCache && _isCacheValid(location)) {
      print('Using cached weather data for $location');
      return _cachedWeather!;
    }

    try {
      // Try to get weather data from AviationWeather.gov API
      // Using their METAR service which provides current weather conditions
      final response = await _dioClient.get(
        '/weather',
        queryParameters: {
          'q': location, // ICAO codes are uppercase
        },
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('No weather data found for $location');
      }

      // Parse the response data
      final weatherData = response.data is List
          ? response.data.first
          : response.data;
      final weather = Weather.fromJson(weatherData);

      // Update cache
      _cachedWeather = weather;
      _cacheTimestamp = DateTime.now();

      return weather;
    } catch (e) {
      throw Exception('Failed to fetch weather data: ${e.toString()}');
    }
  }

  /// Check if cached data is still valid
  bool _isCacheValid(String location) {
    if (_cachedWeather == null || _cacheTimestamp == null) return false;

    final isExpired =
        DateTime.now().difference(_cacheTimestamp!) > cacheDuration;
    final isSameLocation =
        _cachedWeather!.city.toLowerCase() == location.toLowerCase();

    return !isExpired && isSameLocation;
  }

  /// Get the last cached weather data
  Weather? getCachedWeather() => _cachedWeather;

  /// Clear the cache
  void clearCache() {
    _cachedWeather = null;
    _cacheTimestamp = null;
  }

  /// Dispose resources
  void dispose() {
    _dioClient.dispose();
  }
}
