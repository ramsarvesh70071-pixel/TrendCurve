import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trend_curve/app.dart';
import 'package:trend_curve/core/providers/app_providers.dart';
import 'package:trend_curve/data/local/local_storage_service.dart';

void main() {
  testWidgets('Trend Curve app launches and displays splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await LocalStorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storageService),
        ],
        child: const TrendCurveApp(),
      ),
    );

    expect(find.text('Trend Curve'), findsOneWidget);
    expect(find.text('Track. Analyze. Grow.'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
  });
}
