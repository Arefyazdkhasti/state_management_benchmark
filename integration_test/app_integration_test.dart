import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:state_management_benchmark/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('State Management Integration Tests', () {
    testWidgets('should navigate through all state management solutions', (
      tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify home page
      expect(find.text('State Management Benchmark'), findsOneWidget);
      expect(find.text('Choose a State Management Solution'), findsOneWidget);

      // Test Provider
      await _testStateManagementSolution(tester, 'Provider', Colors.blue);

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Test Riverpod
      await _testStateManagementSolution(tester, 'Riverpod', Colors.green);

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Test Bloc
      await _testStateManagementSolution(tester, 'Bloc', Colors.orange);

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Test Cubit
      await _testStateManagementSolution(tester, 'Cubit', Colors.indigo);

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Test GetX
      await _testStateManagementSolution(tester, 'GetX', Colors.teal);
    });

    testWidgets('should handle weather search functionality', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Provider implementation
      await tester.tap(find.text('Provider'));
      await tester.pumpAndSettle();

      // Test weather search
      await _testWeatherSearch(tester, 'New York');

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Navigate to Riverpod implementation
      await tester.tap(find.text('Riverpod'));
      await tester.pumpAndSettle();

      // Test weather search
      await _testWeatherSearch(tester, 'London');
    });

    testWidgets('should handle error states', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Provider implementation
      await tester.tap(find.text('Provider'));
      await tester.pumpAndSettle();

      // Test empty input error
      await tester.tap(find.byKey(ValueKey('search_elevated_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a location'), findsOneWidget);

      // Test invalid city error
      await tester.enterText(find.byType(TextField), 'InvalidCity123');
      await tester.tap(find.byKey(ValueKey('search_elevated_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('not found'), findsOneWidget);
    });

    testWidgets('should handle loading states', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Provider implementation
      await tester.tap(find.text('Provider'));
      await tester.pumpAndSettle();

      // Enter city name
      await tester.enterText(find.byType(TextField), 'New York');

      // Tap search buttons
      await tester.tap(find.byKey(ValueKey('search_elevated_button')));

      // Check for loading indicator immediately
      await tester.pump(); // Don't settle, check immediately
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Should show weather data after loading
      expect(find.textContaining('New York'), findsWidgets);
    });
  });
}

Future<void> _testStateManagementSolution(
  WidgetTester tester,
  String name,
  Color expectedColor,
) async {
  // Tap the state management button
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();

  // Verify navigation to the correct implementation
  expect(find.text('$name Weather'), findsOneWidget);

  // Verify the app bar color matches expected color
  final appBar = tester.widget<AppBar>(find.byType(AppBar));
  expect(appBar.backgroundColor, expectedColor);

  // Verify basic UI elements are present
  expect(find.byType(TextField), findsOneWidget); // City input
  expect(
    find.byKey(ValueKey('search_elevated_button')),
    findsOneWidget,
  ); // Search button
  expect(
    find.text('Weather Information'),
    findsOneWidget,
  ); // Weather display section
}

Future<void> _testWeatherSearch(WidgetTester tester, String cityName) async {
  // Enter city name
  await tester.enterText(find.byType(TextField), cityName);

  // Tap search button
  await tester.tap(find.byKey(ValueKey('search_elevated_button')));

  // Wait for loading and results
  await tester.pumpAndSettle(const Duration(seconds: 10));

  // Verify weather data is displayed
  expect(find.textContaining(cityName), findsWidgets);
  expect(find.textContaining('Temperature'), findsOneWidget);
  expect(find.textContaining('Condition'), findsOneWidget);
  expect(find.textContaining('Wind Speed'), findsOneWidget);
}
