import 'package:get/get.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:state_management_benchmark/models/weather.dart';

class WeatherController extends GetxController {
  final WeatherRepository _repository;

  WeatherController({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository();

  // Observable variables
  var weather = Rx<Weather?>(null);
  var error = Rx<String?>(null);
  var isLoading = false.obs;

  // Getters for easier access
  Weather? get currentWeather => weather.value;
  String? get currentError => error.value;
  bool get isCurrentlyLoading => isLoading.value;

  Future<void> fetchWeather(String location) async {
    if (location.trim().isEmpty) {
      error.value = 'Please enter a location';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final result = await _repository.getWeather(location.trim());
      weather.value = result;
      error.value = null;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      weather.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = null;
  }

  void clearWeather() {
    weather.value = null;
    error.value = null;
  }

  @override
  void onClose() {
    _repository.dispose();
    super.onClose();
  }
}