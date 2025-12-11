/// Application configuration for different environments
enum Flavor {
  /// Production environment
  production,

  /// Staging environment
  staging,

  /// Development environment
  development,
}

/// Configuration class for environment-specific settings
class AppConfig {
  /// Private constructor
  AppConfig(
    this.appName,
    this.authEndpoint,
    this.managementEndpoint,
    this.flavor,
  );

  /// Factory method to create and set the shared instance
  factory AppConfig.create({
    String appName = '',
    String authEndpoint = '',
    String managementEndpoint = '',
    Flavor flavor = Flavor.development,
  }) {
    return shared = AppConfig(
      appName,
      authEndpoint,
      managementEndpoint,
      flavor,
    );
  }

  /// Application name displayed in the UI
  String appName = '';

  /// Base URL for authentication endpoints
  String authEndpoint = '';

  /// Base URL for API management endpoints
  String managementEndpoint = '';

  /// Current application flavor/environment
  Flavor flavor = Flavor.development;

  /// Shared singleton instance
  static AppConfig shared = AppConfig.create();
}
