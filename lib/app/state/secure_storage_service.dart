import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Service that encapsulates all secure storage operations for authentication.
///
/// Uses [FlutterSecureStorage] to store sensitive data like auth tokens
/// in the platform's secure storage (Keychain on iOS, Keystore on Android).
class SecureStorageService {
  /// Creates a [SecureStorageService].
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _sessionIdKey = 'session_id';

  // Token operations

  /// Saves the authentication token to secure storage.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the authentication token from secure storage.
  ///
  /// Returns `null` if no token is stored.
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Deletes the authentication token from secure storage.
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Session ID operations (for OTP flow)

  /// Saves the session ID to secure storage.
  ///
  /// The session ID is used during the OTP confirmation flow.
  Future<void> saveSessionId(String sessionId) async {
    await _storage.write(key: _sessionIdKey, value: sessionId);
  }

  /// Retrieves the session ID from secure storage.
  ///
  /// Returns `null` if no session ID is stored.
  Future<String?> getSessionId() async {
    return _storage.read(key: _sessionIdKey);
  }

  /// Deletes the session ID from secure storage.
  Future<void> deleteSessionId() async {
    await _storage.delete(key: _sessionIdKey);
  }

  // Complete cleanup

  /// Clears all authentication data from secure storage.
  ///
  /// This includes both the auth token and session ID.
  /// Should be called during sign out.
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// Provider for [SecureStorageService].
@riverpod
SecureStorageService secureStorageService(Ref ref) {
  return SecureStorageService(const FlutterSecureStorage());
}
