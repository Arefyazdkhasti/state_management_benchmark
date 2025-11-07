import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/state_management/cubit/weather_cubit.dart';
import 'package:state_management_benchmark/ui/weather_page.dart';

class CubitWeatherApp extends StatelessWidget {
  const CubitWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherCubit(),
      child: const WeatherPage(
        title: 'Cubit Weather',
        body: CubitWeatherBody(),
        primaryColor: Colors.indigo,
      ),
    );
  }
}

class CubitWeatherBody extends StatefulWidget {
  const CubitWeatherBody({super.key});

  @override
  State<CubitWeatherBody> createState() => _CubitWeatherBodyState();
}

class _CubitWeatherBodyState extends State<CubitWeatherBody> {
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
    context.read<WeatherCubit>().fetchWeather(_controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherCubitState>(
      builder: (context, state) {
        bool isLoading = false;
        Weather? weather;
        String? error;

        if (state is WeatherCubitLoading) {
          isLoading = true;
        } else if (state is WeatherCubitLoaded) {
          weather = state.weather;
        } else if (state is WeatherCubitError) {
          error = state.message;
        }

        return Column(
          children: [
            WeatherInputSection(
              controller: _controller,
              onSearch: _handleSearch,
              isLoading: isLoading,
            ),
            Expanded(
              child: WeatherDisplaySection(
                weather: weather,
                error: error,
                isLoading: isLoading,
                onRetry: _handleSearch,
              ),
            ),
          ],
        );
      },
    );
  }
}
