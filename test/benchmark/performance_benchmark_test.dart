import 'package:flutter_test/flutter_test.dart';
import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock repository for testing
class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('Weather Model Performance Benchmarks', () {
    late MockWeatherRepository mockRepository;

    // Sample OpenWeatherMap API response
    final sampleWeatherJson = {
      'coord': {'lon': -74.006, 'lat': 40.7128},
      'weather': [
        {'id': 800, 'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
      ],
      'base': 'stations',
      'main': {
        'temp': 298.15,
        'feels_like': 299.15,
        'temp_min': 297.15,
        'temp_max': 299.15,
        'pressure': 1013,
        'humidity': 60,
      },
      'visibility': 10000,
      'wind': {'speed': 5.1, 'deg': 240},
      'clouds': {'all': 0},
      'dt': 1640995200,
      'sys': {
        'type': 2,
        'id': 2005681,
        'country': 'US',
        'sunrise': 1640976845,
        'sunset': 1641011183,
      },
      'timezone': -18000,
      'id': 5128581,
      'name': 'New York',
    };

    setUp(() {
      mockRepository = MockWeatherRepository();
    });

    test('Weather model JSON parsing performance - 1000 operations', () async {
      // Warm up
      for (int i = 0; i < 100; i++) {
        Weather.fromJson(sampleWeatherJson);
      }

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        Weather.fromJson(sampleWeatherJson);
      }

      stopwatch.stop();

      print(
        'Weather JSON parsing - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per operation: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
      ); // Should complete within 1 second
    });

    test('Weather model object creation performance - 1000 operations', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        Weather(
          city: 'New York',
          temperature: 25.0 + (i % 10), // Varying temperature
          condition: 'Clear',
          description: 'clear sky',
          visibility: 10000.0,
          windSpeed: 5.1 + (i % 5), // Varying wind speed
          windDirection: 'SW',
          pressure: 1013.0,
          humidity: 60 + (i % 20), // Varying humidity
          timestamp: DateTime.now().add(Duration(minutes: i)),
          tempMin: 20.0,
          tempMax: 30.0,
          latitude: 40.7128,
          longitude: -74.0060,
        );
      }

      stopwatch.stop();

      print(
        'Weather object creation - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per creation: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
      ); // Should complete within 500ms
    });

    test('Weather model copyWith performance - 1000 operations', () async {
      final originalWeather = Weather.fromJson(sampleWeatherJson);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        originalWeather.copyWith(
          temperature: 25.0 + (i % 10),
          humidity: 60 + (i % 20),
          windSpeed: 5.1 + (i % 5),
        );
      }

      stopwatch.stop();

      print(
        'Weather copyWith - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per copyWith: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
      ); // Should complete within 300ms
    });

    test('Weather model toJson performance - 1000 operations', () async {
      final weather = Weather.fromJson(sampleWeatherJson);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        weather.toJson();
      }

      stopwatch.stop();

      print(
        'Weather toJson - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per toJson: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(400),
      ); // Should complete within 400ms
    });

    test(
      'Weather model equality comparison performance - 1000 operations',
      () async {
        final weather1 = Weather.fromJson(sampleWeatherJson);
        final weather2 = Weather.fromJson(sampleWeatherJson);
        final weather3 = weather1.copyWith(temperature: 30.0);

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          // Mix of equal and non-equal comparisons
          if (i % 2 == 0) {
            weather1 == weather2; // Equal
          } else {
            weather1 == weather3; // Not equal
          }
        }

        stopwatch.stop();

        print(
          'Weather equality comparison - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
        );
        print(
          'Average time per comparison: ${stopwatch.elapsedMicroseconds / 1000}μs',
        );

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(200),
        ); // Should complete within 200ms
      },
    );

    test('Weather model toString performance - 1000 operations', () async {
      final weather = Weather.fromJson(sampleWeatherJson);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        weather.toString();
      }

      stopwatch.stop();

      print(
        'Weather toString - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per toString: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(300),
      ); // Should complete within 300ms
    });

    test('Memory usage benchmark - creating 1000 Weather objects', () async {
      final stopwatch = Stopwatch()..start();

      final List<Weather> weatherList = [];

      for (int i = 0; i < 1000; i++) {
        weatherList.add(
          Weather.fromJson({
            ...sampleWeatherJson,
            'name': 'City $i',
            'main': {
              'temp': 298.15 + (i % 10),
              'feels_like': 299.15,
              'temp_min': 297.15,
              'temp_max': 299.15,
              'pressure': 1013,
              'humidity': 60,
            },
          }),
        );
      }

      stopwatch.stop();

      print(
        'Created 1000 Weather objects in ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Memory usage: approximately ${weatherList.length * 200} bytes (estimated)',
      );

      expect(weatherList.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      // Clean up
      weatherList.clear();
    });

    test('Concurrent weather operations performance', () async {
      final stopwatch = Stopwatch()..start();

      final futures = <Future<Weather>>[];

      for (int i = 0; i < 100; i++) {
        futures.add(
          Future.value(
            Weather.fromJson({
              ...sampleWeatherJson,
              'name': 'City $i',
              'main': {
                'temp': 298.15 + (i % 10),
                'feels_like': 299.15,
                'temp_min': 297.15,
                'temp_max': 299.15,
                'pressure': 1013,
                'humidity': 60,
              },
            }),
          ),
        );
      }

      final results = await Future.wait(futures);

      stopwatch.stop();

      print(
        'Concurrent weather operations - 100 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per concurrent operation: ${stopwatch.elapsedMicroseconds / 100}μs',
      );

      expect(results.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Large dataset parsing performance', () async {
      final largeDataset = List.generate(
        100,
        (i) => ({
          ...sampleWeatherJson,
          'name': 'City $i',
          'main': {
            'temp': 298.15 + (i % 20),
            'feels_like': 299.15,
            'temp_min': 297.15,
            'temp_max': 299.15,
            'pressure': 1013,
            'humidity': 60,
          },
        }),
      );

      final stopwatch = Stopwatch()..start();

      final List<Weather> weatherObjects = [];
      for (final json in largeDataset) {
        weatherObjects.add(Weather.fromJson(json));
      }

      stopwatch.stop();

      print(
        'Large dataset parsing - 100 weather objects: ${stopwatch.elapsedMilliseconds}ms',
      );
      print('Average time per parse: ${stopwatch.elapsedMicroseconds / 100}μs');

      expect(weatherObjects.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Weather model validation performance', () async {
      final weather = Weather.fromJson(sampleWeatherJson);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        // Simulate validation checks
        _validateWeather(weather);
      }

      stopwatch.stop();

      print(
        'Weather validation - 1000 operations: ${stopwatch.elapsedMilliseconds}ms',
      );
      print(
        'Average time per validation: ${stopwatch.elapsedMicroseconds / 1000}μs',
      );

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}

// Helper function to validate weather data
void _validateWeather(Weather weather) {
  assert(weather.city.isNotEmpty);
  assert(weather.temperature >= -50 && weather.temperature <= 50);
  assert(weather.condition.isNotEmpty);
  assert(weather.visibility >= 0 && weather.visibility <= 50000);
  assert(weather.windSpeed >= 0 && weather.windSpeed <= 200);
  assert(weather.pressure >= 800 && weather.pressure <= 1200);
  assert(weather.humidity >= 0 && weather.humidity <= 100);
}
