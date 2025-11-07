import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:state_management_benchmark/api/weather_repository.dart';
import 'package:state_management_benchmark/models/weather.dart';

// Events
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeatherEvent extends WeatherEvent {
  final String location;

  const FetchWeatherEvent(this.location);

  @override
  List<Object> get props => [location];
}

class ClearWeatherEvent extends WeatherEvent {}

class ClearErrorEvent extends WeatherEvent {}

// States
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded(this.weather);

  @override
  List<Object> get props => [weather];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository _repository;

  WeatherBloc({WeatherRepository? repository})
      : _repository = repository ?? WeatherRepository(),
        super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onFetchWeather);
    on<ClearWeatherEvent>(_onClearWeather);
    on<ClearErrorEvent>(_onClearError);
  }

  Future<void> _onFetchWeather(
    FetchWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    if (event.location.trim().isEmpty) {
      emit(const WeatherError('Please enter a location'));
      return;
    }

    emit(WeatherLoading());

    try {
      final weather = await _repository.getWeather(event.location.trim());
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onClearWeather(ClearWeatherEvent event, Emitter<WeatherState> emit) {
    emit(WeatherInitial());
  }

  void _onClearError(ClearErrorEvent event, Emitter<WeatherState> emit) {
    if (state is WeatherError) {
      emit(WeatherInitial());
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}