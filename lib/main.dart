import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:state_management_benchmark/state_management/bloc/weather_bloc_ui.dart';
import 'package:state_management_benchmark/state_management/cubit/weather_cubit_ui.dart';
import 'package:state_management_benchmark/state_management/getx/weather_getx_ui.dart';
import 'package:state_management_benchmark/state_management/provider/weather_provider.dart';
import 'package:state_management_benchmark/state_management/riverpod/weather_riverpod.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management Benchmark',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('State Management Benchmark'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose a State Management Solution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildStateManagementButton(
              context,
              'Provider',
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => WeatherProvider(),
                    child: const ProviderWeatherApp(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStateManagementButton(
              context,
              'Riverpod',
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProviderScope(child: RiverpodWeatherApp()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStateManagementButton(
              context,
              'Bloc',
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlocWeatherApp()),
              ),
            ),
            const SizedBox(height: 16),
            _buildStateManagementButton(
              context,
              'Cubit',
              Colors.indigo,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CubitWeatherApp(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStateManagementButton(
              context,
              'GetX',
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GetXWeatherApp()),
              ),
            ),
          ],
        )..paddingAll(16),
      ),
    );
  }

  Widget _buildStateManagementButton(
    BuildContext context,
    String title,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
