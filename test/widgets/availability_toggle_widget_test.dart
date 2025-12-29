import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merca_nica/features/delivery/widgets/availability_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('AvailabilityToggle shows loading then toggles via switch', (
    tester,
  ) async {
    // Mock SharedPreferences to avoid platform channels
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: AvailabilityToggle())),
      ),
    );

    // initially shows loading spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // fast-forward the delayed Future inside the widget
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    // after loading, the switch should be present
    expect(find.byType(Switch), findsOneWidget);

    // tap the switch to change state
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // snackbar appears briefly
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
