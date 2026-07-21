class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'AI Store Assistant';
  static const String appNameAr = 'مساعد المتجر الذكي';
  static const String appVersion = '1.0.0';
  static const String appBundleId = 'com.aistoreassistant';

  // Storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyBiometricEnabled = 'biometric_enabled';

  // User roles
  static const String roleMerchant = 'merchant';
  static const String roleWorker = 'worker';
  static const String roleCustomer = 'customer';

  // API
  static const int apiTimeoutSeconds = 30;
  static const int maxRetries = 3;

  // Pagination
  static const int pageSize = 20;

  // Image
  static const double thumbnailSize = 80.0;
  static const double avatarSize = 48.0;

  // Animation durations (ms)
  static const int animFast = 200;
  static const int animNormal = 350;
  static const int animSlow = 600;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 100.0;

  // Padding / spacing
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Low stock threshold
  static const int lowStockThreshold = 10;
}
