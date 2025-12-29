import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merca_nica/core/providers/availability_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Availability provider default and set (with mock prefs)', () async {
    // Ensure SharedPreferences uses mocks in tests
    SharedPreferences.setMockInitialValues({});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // initial should be default (false)
    expect(container.read(availabilityProvider), false);

    // set available
    await container.read(availabilityProvider.notifier).setAvailable(true);
    expect(container.read(availabilityProvider), true);

    // toggle
    await container.read(availabilityProvider.notifier).toggle();
    expect(container.read(availabilityProvider), false);
  });
}
