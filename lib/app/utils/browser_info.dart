import 'package:web/web.dart' as web;

/// Browser information detector for web platform.
///
/// This utility class provides methods to detect browser manufacturer,
/// name, and version when running on the web platform.
///
/// Example usage:
/// ```dart
/// if (kIsWeb) {
///   final manufacturer = BrowserInfo.getManufacturer(); // 'Google', 'Apple', 'Mozilla', 'Microsoft', 'Opera'
///   final model = BrowserInfo.getModel(); // 'Chrome 120.0', 'Safari 17.2', etc.
///   final browserName = BrowserInfo.getBrowserName(); // 'Chrome', 'Safari', 'Firefox', etc.
///   final version = BrowserInfo.getBrowserVersion(); // '120.0', '17.2', etc.
/// }
/// ```
///
/// Supported browsers:
/// - Chrome (Google)
/// - Safari (Apple)
/// - Firefox (Mozilla)
/// - Edge (Microsoft)
/// - Opera (Opera)
class BrowserInfo {
  /// Gets the browser manufacturer/vendor.
  ///
  /// Returns the company that makes the browser:
  /// - 'Microsoft' for Edge
  /// - 'Apple' for Safari
  /// - 'Mozilla' for Firefox
  /// - 'Google' for Chrome
  /// - 'Opera' for Opera
  /// - 'Web' as fallback
  static String getManufacturer() {
    final userAgent = web.window.navigator.userAgent.toLowerCase();

    // Check for Edge (must be before Chrome since Edge includes 'chrome' in UA)
    if (userAgent.contains('edg/') || userAgent.contains('edge/')) {
      return 'Microsoft';
    }

    // Check for Opera (must be before Chrome since Opera includes 'chrome' in UA)
    if (userAgent.contains('opr/') || userAgent.contains('opera')) {
      return 'Opera';
    }

    // Check for Chrome
    if (userAgent.contains('chrome/') && !userAgent.contains('edg')) {
      return 'Google';
    }

    // Check for Safari (must be after Chrome/Edge check)
    if (userAgent.contains('safari/') && !userAgent.contains('chrome')) {
      return 'Apple';
    }

    // Check for Firefox
    if (userAgent.contains('firefox/')) {
      return 'Mozilla';
    }

    return 'Web';
  }

  /// Gets the browser name and version.
  ///
  /// Returns a string like:
  /// - 'Chrome 120.0'
  /// - 'Firefox 121.0'
  /// - 'Safari 17.2'
  /// - 'Edge 120.0'
  /// - 'Opera 106.0'
  /// - 'Web Browser' as fallback
  static String getModel() {
    final userAgent = web.window.navigator.userAgent;

    // Try to extract browser name and version
    final browserInfo = _parseBrowserInfo(userAgent);

    if (browserInfo != null) {
      return '${browserInfo['name']} ${browserInfo['version']}';
    }

    return 'Web Browser';
  }

  /// Gets the full browser name.
  static String getBrowserName() {
    final userAgent = web.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains('edg/') || userAgent.contains('edge/')) {
      return 'Edge';
    }
    if (userAgent.contains('opr/') || userAgent.contains('opera')) {
      return 'Opera';
    }
    if (userAgent.contains('chrome/') && !userAgent.contains('edg')) {
      return 'Chrome';
    }
    if (userAgent.contains('safari/') && !userAgent.contains('chrome')) {
      return 'Safari';
    }
    if (userAgent.contains('firefox/')) {
      return 'Firefox';
    }

    return 'Unknown';
  }

  /// Gets just the browser version.
  static String getBrowserVersion() {
    final userAgent = web.window.navigator.userAgent;
    final browserInfo = _parseBrowserInfo(userAgent);
    return browserInfo?['version'] ?? 'Unknown';
  }

  /// Parses browser information from user agent string.
  static Map<String, String>? _parseBrowserInfo(String userAgent) {
    final patterns = <Map<String, Object>>[
      // Edge (must be first)
      {'regex': RegExp(r'Edg/(\d+\.\d+)'), 'name': 'Edge'},
      {'regex': RegExp(r'Edge/(\d+\.\d+)'), 'name': 'Edge'},

      // Opera (must be before Chrome)
      {'regex': RegExp(r'OPR/(\d+\.\d+)'), 'name': 'Opera'},
      {'regex': RegExp(r'Opera/(\d+\.\d+)'), 'name': 'Opera'},

      // Chrome
      {'regex': RegExp(r'Chrome/(\d+\.\d+)'), 'name': 'Chrome'},

      // Safari (must be after Chrome/Edge)
      {'regex': RegExp(r'Version/(\d+\.\d+).*Safari'), 'name': 'Safari'},

      // Firefox
      {'regex': RegExp(r'Firefox/(\d+\.\d+)'), 'name': 'Firefox'},
    ];

    for (final pattern in patterns) {
      final regex = pattern['regex'];
      final name = pattern['name'];

      if (regex is RegExp && name is String) {
        final match = regex.firstMatch(userAgent);

        if (match != null && match.groupCount >= 1) {
          return {
            'name': name,
            'version': match.group(1) ?? 'Unknown',
          };
        }
      }
    }

    return null;
  }
}
