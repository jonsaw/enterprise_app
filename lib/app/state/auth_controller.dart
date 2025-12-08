import 'dart:io';

import 'package:api_auth/api_auth.dart';
import 'package:enterprise/app/entities/auth.dart';
import 'package:enterprise/app/entities/user_role.dart';
import 'package:enterprise/app/logs/talker.dart';
import 'package:enterprise/app/state/secure_storage_service.dart';
import 'package:enterprise/app_clients.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// Controller for authentication state management.
///
/// Handles sign-in, sign-out, session checking, and manages the authenticated
/// user state throughout the application.
@riverpod
class AuthController extends _$AuthController {
  @override
  Future<Auth?> build() async {
    // Listen to state changes to automatically persist/clear tokens
    listenSelf((_, next) {
      final storage = ref.read(secureStorageServiceProvider);

      // On error, remove the token
      if (next case AsyncError()) {
        storage.deleteToken().ignore();
      }

      // On data change, persist or remove token
      if (next case AsyncData(:final value)) {
        switch (value) {
          case Auth():
            // Token is already saved by confirmSignIn, nothing to do
            break;
          case null:
            storage.deleteToken().ignore();
        }
      }
    });

    // Auto-check session on app start
    return checkSession();
  }

  /// Checks if there's a valid session by verifying the stored token.
  ///
  /// Returns the [Auth] object if a valid session exists, otherwise `null`.
  Future<Auth?> checkSession() async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final token = await storage.getToken();

      if (token == null || token.isEmpty) {
        talker.debug('No token found in storage');
        return null;
      }

      // Verify token with backend
      final client = ref.read(gqlAuthClientProvider);
      final result = await client
          .request<GAuthenticatedData, GAuthenticatedVars>(
            GAuthenticatedReq(),
          )
          .first;

      if (result.hasErrors || result.data?.authenticated == null) {
        talker.warning('Token validation failed', result.graphqlErrors);
        await storage.deleteToken();
        return null;
      }

      final userData = result.data!.authenticated!;
      final role = userData.userId.toUserRole();

      talker.info('Session validated for user: ${userData.email}');

      return Auth(
        userId: userData.userId,
        name: userData.name,
        email: userData.email,
        role: role,
      );
    } on Exception catch (e, st) {
      talker.error('Session check failed', e, st);
      return null;
    }
  }

  /// Initiates the sign-in process by sending credentials to the backend.
  ///
  /// Returns the session ID on success, which is used for OTP confirmation.
  /// Throws an exception if sign-in fails.
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final client = ref.read(gqlAuthClientProvider);

      final result = await client
          .request<GSignInData, GSignInVars>(
            GSignInReq(
              (b) => b.vars.input
                ..email = email
                ..password = password
                ..device = _getDeviceInput(),
            ),
          )
          .first;

      if (result.hasErrors || result.data?.signIn == null) {
        final errorMessage =
            result.graphqlErrors?.firstOrNull?.message ?? 'Sign in failed';
        talker.error('Sign in failed: $errorMessage');
        throw Exception(errorMessage);
      }

      final sessionId = result.data!.signIn;

      // Save session ID for OTP confirmation
      await storage.saveSessionId(sessionId);

      talker.info('Sign in successful, session ID saved');

      return sessionId;
    } catch (e, st) {
      talker.error('Sign in error', e, st);
      rethrow;
    }
  }

  /// Confirms the sign-in with the OTP token.
  ///
  /// On success, saves the JWT token and updates the auth state.
  /// Throws an exception if confirmation fails.
  Future<void> confirmSignIn({
    required String email,
    required String password,
    required String otp,
  }) async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final client = ref.read(gqlAuthClientProvider);

      final sessionId = await storage.getSessionId();
      if (sessionId == null) {
        throw Exception('No session ID found. Please sign in again.');
      }

      final result = await client
          .request<GConfirmSignInData, GConfirmSignInVars>(
            GConfirmSignInReq(
              (b) => b.vars.input
                ..id = sessionId
                ..email = email
                ..password = password
                ..token = otp
                ..device = _getDeviceInput(),
            ),
          )
          .first;

      if (result.hasErrors || result.data?.confirmSignIn == null) {
        final errorMessage =
            result.graphqlErrors?.firstOrNull?.message ?? 'Invalid OTP';
        talker.error('OTP confirmation failed: $errorMessage');
        throw Exception(errorMessage);
      }

      final jwtToken = result.data!.confirmSignIn;

      // Save JWT token
      await storage.saveToken(jwtToken);
      await storage.deleteSessionId(); // Clean up session ID

      talker.info('Sign in confirmed, token saved');

      // Fetch user data and update state
      final auth = await checkSession();
      state = AsyncData(auth);
    } catch (e, st) {
      talker.error('Confirm sign in error', e, st);
      rethrow;
    }
  }

  /// Resends the OTP code to the user's email.
  ///
  /// Throws an exception if resend fails.
  Future<void> resendOtp({
    required String email,
    required String password,
  }) async {
    try {
      final storage = ref.read(secureStorageServiceProvider);
      final client = ref.read(gqlAuthClientProvider);

      final sessionId = await storage.getSessionId();
      if (sessionId == null) {
        throw Exception('No session ID found. Please sign in again.');
      }

      final result = await client
          .request<GResendConfirmSignInData, GResendConfirmSignInVars>(
            GResendConfirmSignInReq(
              (b) => b.vars.input
                ..id = sessionId
                ..email = email
                ..password = password
                ..device = _getDeviceInput(),
            ),
          )
          .first;

      if (result.hasErrors) {
        final errorMessage =
            result.graphqlErrors?.firstOrNull?.message ?? 'Resend OTP failed';
        talker.error('Resend OTP failed: $errorMessage');
        throw Exception(errorMessage);
      }

      talker.info('OTP resent successfully');
    } catch (e, st) {
      talker.error('Resend OTP error', e, st);
      rethrow;
    }
  }

  /// Signs out the current user.
  ///
  /// Clears all authentication data from storage and resets the state.
  /// Token deletion is handled automatically by listenSelf.
  Future<void> signOut() async {
    try {
      final client = ref.read(gqlAuthClientProvider);

      // Call sign out mutation
      await client.request<GSignOutData, GSignOutVars>(GSignOutReq()).first;

      talker.info('User signed out');
    } on Exception catch (e, st) {
      talker.error('Sign out error', e, st);
    } finally {
      // Reset state - listenSelf will handle token deletion
      final storage = ref.read(secureStorageServiceProvider);
      await storage.clearAll(); // Clear session ID and any other data
      state = const AsyncData(null);
    }
  }

  /// Gets device information for GraphQL mutations.
  GDeviceInputBuilder _getDeviceInput() {
    return GDeviceInputBuilder()
      ..deviceType = _getDeviceType()
      ..manufacturer = _getManufacturer()
      ..model = _getModel()
      ..isPhysical = !kIsWeb;
  }

  /// Determines the device type based on the platform.
  GDeviceType _getDeviceType() {
    if (kIsWeb) return GDeviceType.WEB;
    if (Platform.isIOS) return GDeviceType.I_OS;
    if (Platform.isMacOS) return GDeviceType.MAC_OS;
    if (Platform.isAndroid) return GDeviceType.ANDROID;
    if (Platform.isWindows) return GDeviceType.WINDOWS;
    if (Platform.isLinux) return GDeviceType.LINUX;
    return GDeviceType.UNKNOWN;
  }

  /// Gets the device manufacturer.
  String? _getManufacturer() {
    if (Platform.isIOS || Platform.isMacOS) return 'Apple';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isWindows) return 'Microsoft';
    if (Platform.isLinux) return 'Linux';
    return null;
  }

  /// Gets the device model.
  String? _getModel() {
    // In a real app, you'd use device_info_plus to get actual model
    // For now, return basic platform info
    if (Platform.isIOS) return 'iOS Device';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isLinux) return 'Linux PC';
    return null;
  }
}
