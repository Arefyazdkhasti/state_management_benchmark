import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/ui/weather_page.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherRepository _repository;

  Weather? _weather;
  String? _error;
  bool _isLoading = false;

  WeatherProvider({WeatherRepository? repository})
    : _repository = repository ?? WeatherRepository();

  // Getters
  Weather? get weather => _weather;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather(String location) async {
    if (location.trim().isEmpty) {
      _error = 'Please enter a location';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _repository.getWeather(location.trim());
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearWeather() {
    _weather = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

class ProviderWeatherApp extends StatelessWidget {
  const ProviderWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const WeatherPage(
        title: 'Provider Weather',
        body: ProviderWeatherBody(),
        primaryColor: Colors.purple,
      ),
    );
  }
}

class ProviderWeatherBody extends StatefulWidget {
  const ProviderWeatherBody({super.key});

  @override
  State<ProviderWeatherBody> createState() => _ProviderWeatherBodyState();
}

class _ProviderWeatherBodyState extends State<ProviderWeatherBody> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final provider = context.read<WeatherProvider>();
    provider.fetchWeather(_controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            WeatherInputSection(
              controller: _controller,
              onSearch: _handleSearch,
              isLoading: provider.isLoading,
            ),
            Expanded(
              child: WeatherDisplaySection(
                weather: provider.weather,
                error: provider.error,
                isLoading: provider.isLoading,
                onRetry: _handleSearch,
              ),
            ),
          ],
        );
      },
    );
  }
}
