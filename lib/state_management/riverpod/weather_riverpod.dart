import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/ui/weather_page.dart';

// Providers
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
      final repository = ref.watch(weatherRepositoryProvider);
      return WeatherNotifier(repository);
    });

// State classes
class WeatherState {
  final Weather? weather;
  final String? error;
  final bool isLoading;

  const WeatherState({this.weather, this.error, this.isLoading = false});

  WeatherState copyWith({Weather? weather, String? error, bool? isLoading}) {
    return WeatherState(
      weather: weather ?? this.weather,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Notifier
class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherRepository _repository;

  WeatherNotifier(this._repository) : super(const WeatherState());

  Future<void> fetchWeather(String location) async {
    if (location.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a location');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final weather = await _repository.getWeather(location.trim());
      state = state.copyWith(weather: weather, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
        weather: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearWeather() {
    state = const WeatherState();
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

// UI
class RiverpodWeatherApp extends StatelessWidget {
  const RiverpodWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: const WeatherPage(
        title: 'Riverpod Weather',
        body: RiverpodWeatherBody(),
        primaryColor: Colors.teal,
      ),
    );
  }
}

class RiverpodWeatherBody extends ConsumerStatefulWidget {
  const RiverpodWeatherBody({super.key});

  @override
  ConsumerState<RiverpodWeatherBody> createState() =>
      _RiverpodWeatherBodyState();
}

class _RiverpodWeatherBodyState extends ConsumerState<RiverpodWeatherBody> {
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
    ref.read(weatherNotifierProvider.notifier).fetchWeather(_controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);

    return Column(
      children: [
        WeatherInputSection(
          controller: _controller,
          onSearch: _handleSearch,
          isLoading: weatherState.isLoading,
        ),
        Expanded(
          child: WeatherDisplaySection(
            weather: weatherState.weather,
            error: weatherState.error,
            isLoading: weatherState.isLoading,
            onRetry: _handleSearch,
          ),
        ),
      ],
    );
  }
}
