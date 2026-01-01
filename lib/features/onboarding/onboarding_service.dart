import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_env.dart';

enum OnboardingRole {
  buyer,
  delivery,
  fleet,
}

class OnboardingService {
  static String _keyFor(String userId, OnboardingRole role) {
    return 'onboarding_${AppConfig.env.name}_${userId}_${role.name}';
  }

  static Future<bool> hasCompletedOnboarding(
    String userId,
    OnboardingRole role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFor(userId, role)) ?? false;
  }

  static Future<void> markOnboardingCompleted(
    String userId,
    OnboardingRole role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(userId, role), true);
  }
}
