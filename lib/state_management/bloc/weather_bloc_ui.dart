import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:state_management_benchmark/models/weather.dart';
import 'package:state_management_benchmark/state_management/bloc/weather_bloc.dart';
import 'package:state_management_benchmark/ui/weather_page.dart';

class BlocWeatherApp extends StatelessWidget {
  const BlocWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherBloc(),
      child: const WeatherPage(
        title: 'Bloc Weather',
        body: BlocWeatherBody(),
        primaryColor: Colors.orange,
      ),
    );
  }
}

class BlocWeatherBody extends StatefulWidget {
  const BlocWeatherBody({super.key});

  @override
  State<BlocWeatherBody> createState() => _BlocWeatherBodyState();
}

class _BlocWeatherBodyState extends State<BlocWeatherBody> {
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
    context.read<WeatherBloc>().add(FetchWeatherEvent(_controller.text));
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        bool isLoading = false;
        Weather? weather;
        String? error;

        if (state is WeatherLoading) {
          isLoading = true;
        } else if (state is WeatherLoaded) {
          weather = state.weather;
        } else if (state is WeatherError) {
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
