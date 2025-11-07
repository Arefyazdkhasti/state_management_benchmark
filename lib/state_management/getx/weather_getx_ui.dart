import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:state_management_benchmark/state_management/getx/weather_controller.dart';
import 'package:state_management_benchmark/ui/weather_page.dart';

class GetXWeatherApp extends StatelessWidget {
  const GetXWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeatherPage(
      title: 'GetX Weather',
      body: GetXWeatherBody(),
      primaryColor: Colors.teal,
    );
  }
}

class GetXWeatherBody extends StatelessWidget {
  const GetXWeatherBody({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<WeatherController>(
      WeatherController(),
      tag: 'weather_getx',
    );

    final TextEditingController textController = TextEditingController();

    void handleSearch() {
      controller.fetchWeather(textController.text);
      FocusScope.of(context).unfocus();
    }

    return Column(
      children: [
        Obx(
          () => WeatherInputSection(
            controller: textController,
            onSearch: handleSearch,
            isLoading: controller.isCurrentlyLoading,
          ),
        ),
        Expanded(
          child: Obx(
            () => WeatherDisplaySection(
              weather: controller.currentWeather,
              error: controller.currentError,
              isLoading: controller.isCurrentlyLoading,
              onRetry: handleSearch,
            ),
          ),
        ),
      ],
    );
  }
}
