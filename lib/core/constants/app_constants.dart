class AppConstants {
  // App Info
  static const String appName = 'SafeBite';
  static const String appTagline = 'Eat smart. Live well.';

  // API
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v2';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String profileKey = 'user_profile';
  static const String onboardingKey = 'onboarding_done';

  // PHSS Score Thresholds
  static const double phssSafe = 80.0;
  static const double phssCaution = 50.0;

  // PHSS Weights
  static const double weightH = 0.40; // Health-related dietary needs
  static const double weightN = 0.30; // Nutrition goals
  static const double weightD = 0.20; // Dietary preferences
  static const double weightG = 0.10; // General ingredient suitability
}
