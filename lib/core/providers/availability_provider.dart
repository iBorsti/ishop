import 'package:flutter_riverpod/flutter_riverpod.dart';

final availabilityProvider = StateNotifierProvider<AvailabilityNotifier, bool>((ref) {
  return AvailabilityNotifier();
});

class AvailabilityNotifier extends StateNotifier<bool> {
  AvailabilityNotifier() : super(false);

  void setAvailable(bool v) => state = v;

  void toggle() => state = !state;
}
