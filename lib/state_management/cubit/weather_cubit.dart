import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:state_management_benchmark/models/weather.dart';

// States (same as Bloc for consistency)
abstract class WeatherCubitState extends Equatable {
  const WeatherCubitState();

  @override
  List<Object> get props => [];
}

class WeatherCubitInitial extends WeatherCubitState {}

class WeatherCubitLoading extends WeatherCubitState {}

class WeatherCubitLoaded extends WeatherCubitState {
  final Weather weather;

  const WeatherCubitLoaded(this.weather);

  @override
  List<Object> get props => [weather];
}

class WeatherCubitError extends WeatherCubitState {
  final String message;

  const WeatherCubitError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit (simpler than Bloc - no events needed)
class WeatherCubit extends Cubit<WeatherCubitState> {
  final WeatherRepository _repository;

  WeatherCubit({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository(),
        super(WeatherCubitInitial());

  Future<void> fetchWeather(String location) async {
    if (location.trim().isEmpty) {
      emit(const WeatherCubitError('Please enter a location'));
      return;
    }

    emit(WeatherCubitLoading());

    try {
      final weather = await _repository.getWeather(location.trim());
      emit(WeatherCubitLoaded(weather));
    } catch (e) {
      emit(WeatherCubitError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void clearWeather() {
    emit(WeatherCubitInitial());
  }

  void clearError() {
    if (state is WeatherCubitError) {
      emit(WeatherCubitInitial());
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}