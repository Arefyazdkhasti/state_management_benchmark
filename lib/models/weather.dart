class Weather {
  final String city;
  final double temperature; // Celsius
  final String condition;
  final String description;
  final double visibility; // meters
  final double windSpeed; // m/s
  final String windDirection; // cardinal direction
  final double pressure; // hPa
  final int humidity; // %
  final DateTime timestamp;
  final double? tempMin;
  final double? tempMax;
  final double? latitude;
  final double? longitude;

  Weather({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.visibility,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.humidity,
    required this.timestamp,
    this.tempMin,
    this.tempMax,
    this.latitude,
    this.longitude,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherData = (json['weather'] as List?)?.isNotEmpty == true
        ? json['weather'][0]
        : null;
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final coord = json['coord'] ?? {};

    return Weather(
      city: json['name'] ?? 'Unknown',
      temperature: _kelvinToCelsius(main['temp']),
      condition: weatherData?['main'] ?? 'Unknown',
      description: weatherData?['description'] ?? 'No description',
      visibility: (json['visibility'] ?? 0).toDouble(),
      windSpeed: _parseDouble(wind['speed']),
      windDirection: _degreeToDirection(_parseDouble(wind['deg'])),
      pressure: _parseDouble(main['pressure']),
      humidity: (main['humidity'] ?? 0).toInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] ?? 0) * 1000,
        isUtc: true,
      ),
      tempMin: _kelvinToCelsius(main['temp_min']),
      tempMax: _kelvinToCelsius(main['temp_max']),
      latitude: _parseDouble(coord['lat']),
      longitude: _parseDouble(coord['lon']),
    );
  }

  static double _kelvinToCelsius(dynamic k) {
    if (k == null) return 0.0;
    if (k is num) return (k - 273.15).toDouble();
    return double.tryParse(k.toString())?.let((v) => v - 273.15) ?? 0.0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String _degreeToDirection(double degree) {
    if (degree.isNaN) return 'N/A';
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((degree / 22.5) + 0.5).floor() % 16;
    return directions[index];
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'description': description,
      'visibility': visibility,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'pressure': pressure,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
      'tempMin': tempMin,
      'tempMax': tempMax,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Weather copyWith({
    String? city,
    double? temperature,
    String? condition,
    String? description,
    double? visibility,
    double? windSpeed,
    String? windDirection,
    double? pressure,
    int? humidity,
    DateTime? timestamp,
    double? tempMin,
    double? tempMax,
    double? latitude,
    double? longitude,
  }) {
    return Weather(
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      pressure: pressure ?? this.pressure,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'Weather(city: $city, temp: ${temperature.toStringAsFixed(1)}°C, '
        'cond: $condition, wind: ${windSpeed.toStringAsFixed(1)} m/s $windDirection, '
        'vis: ${visibility.toStringAsFixed(0)} m, pressure: $pressure hPa, humidity: $humidity%)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          temperature == other.temperature &&
          condition == other.condition &&
          description == other.description &&
          visibility == other.visibility &&
          windSpeed == other.windSpeed &&
          windDirection == other.windDirection &&
          pressure == other.pressure &&
          humidity == other.humidity &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      city.hashCode ^
      temperature.hashCode ^
      condition.hashCode ^
      description.hashCode ^
      visibility.hashCode ^
      windSpeed.hashCode ^
      windDirection.hashCode ^
      pressure.hashCode ^
      humidity.hashCode ^
      timestamp.hashCode;
}

extension _Let<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
