import 'package:enterprise/app/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

/// Sign-in page with two-step authentication flow.
///
/// Step 1: User enters email and password
/// Step 2: User enters OTP sent to their email
class SignInPage extends ConsumerStatefulWidget {
  /// Creates a [SignInPage].
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpStep = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      setState(() {
        _isOtpStep = true;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirmSignIn() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .confirmSignIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            otp: _otpController.text.trim(),
          );

      // Success - router will handle navigation
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .resendOtp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _handleUseDeifferentAccount() {
    setState(() {
      _isOtpStep = false;
      _otpController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FScaffold(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App branding
                Text(
                  'Enterprise',
                  style: theme.typography.xl4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isOtpStep
                      ? 'Enter verification code'
                      : 'Sign in to continue',
                  style: theme.typography.base.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colors.destructive.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colors.destructive,
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.destructive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                FTextField(
                  controller: _emailController,
                  label: const Text('Email'),
                  hint: 'enter@example.com',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isOtpStep && !_isLoading,
                ),
                const SizedBox(height: 16),

                // Password field
                FTextField(
                  controller: _passwordController,
                  label: const Text('Password'),
                  hint: 'Enter your password',
                  obscureText: true,
                  enabled: !_isOtpStep && !_isLoading,
                ),

                // OTP field (shown in step 2)
                if (_isOtpStep) ...[
                  const SizedBox(height: 16),
                  FTextField(
                    controller: _otpController,
                    label: const Text('Verification Code'),
                    hint: 'Enter the code sent to your email',
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                  ),
                ],

                const SizedBox(height: 24),

                // Submit button
                FButton(
                  onPress: _isLoading
                      ? null
                      : (_isOtpStep ? _handleConfirmSignIn : _handleSignIn),
                  child: Text(
                    _isLoading
                        ? 'Please wait...'
                        : _isOtpStep
                        ? 'Verify & Sign In'
                        : 'Continue',
                  ),
                ),

                // Additional actions for OTP step
                if (_isOtpStep) ...[
                  const SizedBox(height: 12),
                  FButton(
                    style: FButtonStyle.outline(),
                    onPress: _isLoading ? null : _handleResendOtp,
                    child: const Text('Resend Code'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isLoading ? null : _handleUseDeifferentAccount,
                    child: Text(
                      'Use Different Account',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
