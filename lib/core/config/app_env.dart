enum AppEnv {
  demo,
  pilot,
  production,
}

class AppConfig {
  static AppEnv env = AppEnv.demo;

  static bool get isDemo => env == AppEnv.demo;
  static bool get isPilot => env == AppEnv.pilot;
  static bool get isProduction => env == AppEnv.production;
}
