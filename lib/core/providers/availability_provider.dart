import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final availabilityProvider = StateNotifierProvider<AvailabilityNotifier, bool>((ref) {
  return AvailabilityNotifier(ref);
});

class AvailabilityNotifier extends StateNotifier<bool> {
  final Ref ref;

  AvailabilityNotifier(this.ref) : super(false) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final v = prefs.getBool('availability') ?? false;
      state = v;
    } catch (_) {
      state = false;
    }
  }

  Future<void> setAvailable(bool v) async {
    state = v;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('availability', v);
    } catch (_) {}
  }

  Future<void> toggle() async => setAvailable(!state);
}
