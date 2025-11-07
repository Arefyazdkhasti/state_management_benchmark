import 'package:flutter/material.dart';
import 'package:state_management_benchmark/models/weather.dart';

class WeatherPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Color primaryColor;

  const WeatherPage({
    super.key,
    required this.title,
    required this.body,
    this.primaryColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: body,
    );
  }
}

class WeatherInputSection extends StatefulWidget {
  final TextEditingController controller;
  final Function onSearch;
  final bool isLoading;
  final String hintText;

  const WeatherInputSection({
    super.key,
    required this.controller,
    required this.onSearch,
    this.isLoading = false,
    this.hintText = 'Enter city or ICAO code (e.g., KJFK, London)',
  });

  @override
  State<WeatherInputSection> createState() => _WeatherInputSectionState();
}

class _WeatherInputSectionState extends State<WeatherInputSection> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Weather Lookup',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabled: !widget.isLoading,
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  widget.onSearch();
                }
              },
              onChanged: (value) {
                print('onChanged : $value');
              },
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: const ValueKey('search_elevated_button'),
              onPressed: widget.isLoading ? null : () => widget.onSearch(),
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(widget.isLoading ? 'Searching...' : 'Get Weather'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDisplaySection extends StatelessWidget {
  final Weather? weather;
  final String? error;
  final bool isLoading;
  final VoidCallback? onRetry;

  const WeatherDisplaySection({
    super.key,
    this.weather,
    this.error,
    this.isLoading = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading weather data...'),
              ],
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (weather == null) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny_outlined, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'No weather data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter a city or ICAO code to get started',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getWeatherIcon(weather!.condition),
                  size: 48,
                  color: _getWeatherColor(weather!.condition),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather!.city,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather!.condition,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${weather!.temperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getWeatherColor(weather!.condition),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _WeatherDetailRow(
              icon: Icons.visibility,
              label: 'Visibility',
              value: '${weather!.visibility.toStringAsFixed(1)} SM',
            ),
            const SizedBox(height: 12),
            _WeatherDetailRow(
              icon: Icons.air,
              label: 'Wind',
              value:
                  '${weather!.windSpeed.toStringAsFixed(1)} KT ${weather!.windDirection}',
            ),
            const SizedBox(height: 12),
            _WeatherDetailRow(
              icon: Icons.access_time,
              label: 'Last Updated',
              value: _formatTimestamp(weather!.timestamp),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.toLowerCase().contains('clear')) return Icons.wb_sunny;
    if (condition.toLowerCase().contains('cloud')) return Icons.cloud;
    if (condition.toLowerCase().contains('rain')) return Icons.umbrella;
    if (condition.toLowerCase().contains('snow')) return Icons.ac_unit;
    if (condition.toLowerCase().contains('fog')) return Icons.cloud_queue;
    return Icons.wb_sunny_outlined;
  }

  Color _getWeatherColor(String condition) {
    if (condition.toLowerCase().contains('clear')) return Colors.orange;
    if (condition.toLowerCase().contains('cloud')) return Colors.grey;
    if (condition.toLowerCase().contains('rain')) return Colors.blue;
    if (condition.toLowerCase().contains('snow')) return Colors.lightBlue;
    if (condition.toLowerCase().contains('fog')) return Colors.grey;
    return Colors.orange;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class _WeatherDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
