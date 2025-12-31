/// Stub implementation of BrowserInfo for non-web platforms.
///
/// This stub is used when compiling for mobile/desktop platforms
/// to avoid JS interop errors from the web-specific implementation.
class BrowserInfo {
  /// Gets the browser manufacturer (stub - returns 'Unknown' on non-web).
  static String getManufacturer() => 'Unknown';

  /// Gets the browser model (stub - returns 'Unknown' on non-web).
  static String getModel() => 'Unknown';

  /// Gets the browser name (stub - returns 'Unknown' on non-web).
  static String getBrowserName() => 'Unknown';

  /// Gets the browser version (stub - returns 'Unknown' on non-web).
  static String getBrowserVersion() => 'Unknown';
}
