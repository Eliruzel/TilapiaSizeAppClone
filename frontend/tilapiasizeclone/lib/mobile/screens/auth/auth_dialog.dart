import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/api_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/mobile_colors.dart';
import '../../../theme/web_colors.dart';
import '../../../website/screens/farmer_dashboard.dart';
import '../../widgets/connection_error_dialog.dart';
import '../../../shared/widgets/page_entrance.dart';
import '../../widgets/terms_dialog.dart';
import '../../../screens/farmer/farmer_dashboard.dart';
import '../guest/landing_screen.dart';
import './forgot_password.dart';
import './new_password.dart';
import './signup.dart';
import './verify_email.dart';
import './verify_reset_code.dart';

Future<void> showAuthDialog(
  BuildContext context, {
  AuthMode initialMode = AuthMode.login,
  bool returnToLoginOnSignup = false,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => AuthDialog(
      initialMode: initialMode,
      returnToLoginOnSignup: returnToLoginOnSignup,
    ),
  );
}

enum AuthMode {
  login,
  register,
  forgotPassword,
  verifyOtp,
  verifyResetOtp,
  newPassword,
}

class AuthDialog extends StatefulWidget {
  const AuthDialog({
    super.key,
    this.resetFromProfile = false,
    this.email = '',
    this.initialMode = AuthMode.login,
    this.returnToLoginOnSignup = false,
    this.webPage = false,
  });

  final bool resetFromProfile;
  final String email;
  final AuthMode initialMode;
  final bool returnToLoginOnSignup;
  final bool webPage;

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  static const _registerNavy = Color(0xFF102B76);
  static const _registerInk = Color(0xFF14254B);

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();

  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _registerEmailFocusNode = FocusNode();
  final _registerPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late AuthMode _mode = widget.resetFromProfile
      ? AuthMode.forgotPassword
      : widget.initialMode;

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  bool get _mobileRegisterStyle =>
      _isMobilePlatform && _mode == AuthMode.register;
  bool get _mobilePageStyle =>
      _isMobilePlatform &&
      _mode != AuthMode.login &&
      _mode != AuthMode.register;
  bool get _mobileFormStyle => _mobileRegisterStyle || _mobilePageStyle;
  Color get _authMutedColor => _isMobilePlatform
      ? const Color(0xFF657390)
      : kIsWeb
      ? WebColors.muted
      : AppColors.muted;
  Color get _authAccentColor => _isMobilePlatform
      ? _registerNavy
      : kIsWeb
      ? WebColors.accent
      : AppColors.mint;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  String _verificationEmail = '';
  String _resetEmail = '';
  String _resetToken = '';

  static const int _maximumAttempts = 5;
  static const int _otpDuration = 120;
  static const int _resendCooldown = 60;

  int _failedAttempts = 0;
  int _resetFailedAttempts = 0;

  DateTime? _otpExpiresAt;
  DateTime? _resendAvailableAt;

  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otpController.dispose();

    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _nameFocusNode.dispose();
    _registerEmailFocusNode.dispose();
    _registerPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  int _secondsUntil(DateTime? deadline) {
    if (deadline == null) return 0;

    final milliseconds = deadline.difference(DateTime.now()).inMilliseconds;

    if (milliseconds <= 0) return 0;

    return (milliseconds + 999) ~/ 1000;
  }

  int get _otpSecondsLeft => _secondsUntil(_otpExpiresAt);

  int get _resendSecondsLeft => _secondsUntil(_resendAvailableAt);

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainder.toString().padLeft(2, '0')}';
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted ||
          (_mode != AuthMode.verifyOtp && _mode != AuthMode.verifyResetOtp)) {
        timer.cancel();
        return;
      }

      setState(() {});

      if (_otpSecondsLeft == 0 && _resendSecondsLeft == 0) {
        timer.cancel();
      }
    });
  }

  void _startOtpTimer() {
    final now = DateTime.now();

    setState(() {
      _otpExpiresAt = now.add(const Duration(seconds: _otpDuration));

      _resendAvailableAt = now.add(const Duration(seconds: _resendCooldown));
    });

    _startCountdown();
  }

  void _changeMode(AuthMode mode) {
    if (_isMobilePlatform) FocusScope.of(context).unfocus();

    if (mode != AuthMode.verifyOtp && mode != AuthMode.verifyResetOtp) {
      _countdownTimer?.cancel();
    }

    setState(() {
      _mode = mode;
      _formKey = GlobalKey<FormState>();
      _hidePassword = true;
      _hideConfirm = true;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showLoginPopup(
    String title,
    String message,
    IconData icon,
    Color iconColor,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF103A3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFCEE0DE)),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMobilePlatform
                      ? _registerNavy
                      : kIsWeb
                      ? WebColors.accent
                      : AppColors.mint,
                  foregroundColor: _isMobilePlatform || kIsWeb
                      ? Colors.white
                      : AppColors.background,
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================
  // LOGIN
  // ============================================

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final user = result['user'];

      final account = user is Map
          ? Map<String, dynamic>.from(user)
          : <String, dynamic>{};

      if (!mounted) return;
      // Open the dashboard and remove the login dialog
      // and guest page from the navigation stack.
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        PageRouteBuilder<void>(
          transitionDuration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 350),
          pageBuilder: (_, animation, secondaryAnimation) => kIsWeb
              ? WebFarmerDashboard(account: account)
              : FarmerDashboard(account: account),
          transitionsBuilder: (_, animation, secondaryAnimation, child) =>
              SmoothPageTransition(
                animation: animation,
                distance: 0,
                blur: 5,
                child: child,
              ),
        ),
        (route) => false,
      );
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      String title = 'Login Failed';
      IconData icon = Icons.error_outline;
      Color color = Colors.redAccent;

      if (error.statusCode == 404) {
        title = 'Account Not Found';
        icon = Icons.person_off_outlined;
      } else if (error.statusCode == 401) {
        title = 'Incorrect Credentials';
        icon = Icons.lock_outline;
      } else if (error.statusCode == 403) {
        title = 'Email Not Verified';
        icon = Icons.mark_email_unread_outlined;
        color = Colors.orangeAccent;
      }

      await _showLoginPopup(title, error.message, icon, color);
    } catch (_) {
      if (!mounted) return;

      await _showLoginPopup(
        'Something Went Wrong',
        'Please try again later.',
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // REGISTER ACCOUNT
  // ============================================

  Future<void> _register() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      _showMessage('Please accept the Terms and Conditions.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      _verificationEmail =
          result['email']?.toString() ?? _emailController.text.trim();

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
      _otpController.clear();

      _failedAttempts = 0;

      setState(() => _acceptedTerms = false);

      _changeMode(AuthMode.verifyOtp);
      _startOtpTimer();
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      await _showLoginPopup(
        error.statusCode == 409
            ? 'Email Already Registered'
            : 'Registration Failed',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } catch (_) {
      if (!mounted) return;

      await _showLoginPopup(
        'Something Went Wrong',
        'Please try again later.',
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // VERIFY REGISTRATION OTP
  // ============================================

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.verifyOtp(
        email: _verificationEmail,
        otpCode: _otpController.text.trim(),
      );

      if (!mounted) return;

      _countdownTimer?.cancel();

      await _showLoginPopup(
        'Email Verified',
        'Your TilapiaSize account has been created successfully!',
        Icons.check_circle_outline,
        Colors.greenAccent,
      );

      if (!mounted) return;

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
      _otpController.clear();

      Navigator.of(context).pop();
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.message.contains('Incorrect OTP')) {
        setState(() => _failedAttempts++);
      } else if (error.statusCode == 429) {
        setState(() {
          _failedAttempts = _maximumAttempts;
        });
      }

      await _showLoginPopup(
        'Verification Failed',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // RESEND REGISTRATION OTP
  // ============================================

  Future<void> _resendOtp() async {
    if (_isLoading || _resendSecondsLeft > 0) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.resendOtp(email: _verificationEmail);

      if (!mounted) return;

      _otpController.clear();
      _failedAttempts = 0;

      _startOtpTimer();

      _showMessage('A new verification code was sent to your email.');
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      await _showLoginPopup(
        'Unable to Resend Code',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // FORGOT PASSWORD
  // ============================================

  Future<void> _forgotPassword() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();

      await ApiService.forgotPassword(email: email);

      if (!mounted) return;

      _resetEmail = email;
      _resetToken = '';
      _resetFailedAttempts = 0;

      _otpController.clear();

      // Automatically open reset OTP entry.
      _changeMode(AuthMode.verifyResetOtp);
      _startOtpTimer();

      _showMessage(
        'If an account exists, check your email for the reset code.',
      );
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      await _showLoginPopup(
        'Password Reset Failed',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // VERIFY PASSWORD RESET OTP
  // ============================================

  Future<void> _verifyResetOtp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_otpSecondsLeft == 0) {
      _showMessage('OTP expired. Please request a new code.');
      return;
    }

    if (_resetFailedAttempts >= _maximumAttempts) {
      _showMessage('Maximum attempts reached.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.verifyResetOtp(
        email: _resetEmail,
        otpCode: _otpController.text.trim(),
      );

      if (!mounted) return;

      final token = result['reset_token'];

      if (token is! String || token.isEmpty) {
        throw const FormatException('Reset token was not returned.');
      }

      _resetToken = token;

      _countdownTimer?.cancel();
      _otpController.clear();

      // Correct OTP opens new password screen.
      _changeMode(AuthMode.newPassword);
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      if (error.message.contains('Incorrect OTP')) {
        setState(() {
          _resetFailedAttempts++;
        });
      } else if (error.statusCode == 429) {
        setState(() {
          _resetFailedAttempts = _maximumAttempts;
        });
      }

      await _showLoginPopup(
        'Verification Failed',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } catch (_) {
      if (!mounted) return;

      await _showLoginPopup(
        'Verification Failed',
        'Unable to verify your reset code.',
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // CREATE NEW PASSWORD
  // ============================================

  Future<void> _resetPassword() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_resetToken.isEmpty) {
      _showMessage('Please verify your reset code again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.resetPassword(
        resetToken: _resetToken,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      await _showLoginPopup(
        'Password Updated',
        widget.resetFromProfile
            ? 'Your password has been changed successfully. Use your new password the next time you log in.'
            : 'Your password has been changed successfully. '
                  'You can now log in using your new password.',
        Icons.check_circle_outline,
        Colors.greenAccent,
      );

      if (!mounted) return;

      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
      _passwordController.clear();
      _otpController.clear();
      _emailController.clear();

      _resetEmail = '';
      _resetToken = '';

      if (widget.resetFromProfile) {
        Navigator.of(context).pop(true);
        return;
      }

      // Return to Login screen.
      _changeMode(AuthMode.login);
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      await _showLoginPopup(
        'Password Reset Failed',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // RESEND PASSWORD RESET OTP
  // ============================================

  Future<void> _resendPasswordResetOtp() async {
    if (_isLoading || _resendSecondsLeft > 0) return;

    setState(() => _isLoading = true);

    try {
      await ApiService.forgotPassword(email: _resetEmail);

      if (!mounted) return;

      _otpController.clear();
      _resetFailedAttempts = 0;

      _startOtpTimer();

      _showMessage('If an account exists, a reset code has been requested.');
    } on ServerUnavailableException {
      if (!mounted) return;
      await ConnectionErrorDialog.show(context);
    } on ApiException catch (error) {
      if (!mounted) return;

      await _showLoginPopup(
        'Unable to Request Code',
        error.message,
        Icons.error_outline,
        Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // MAIN AUTHENTICATION DIALOG
  // ============================================

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && widget.webPage) return _buildWebAuthPage();

    if (_isMobilePlatform) {
      switch (_mode) {
        case AuthMode.register:
          return _buildRegisterPage();
        case AuthMode.forgotPassword:
          return ForgotPasswordScreen(
            form: Form(key: _formKey, child: _buildForgotPasswordForm()),
            onHome: () => _openLandingFromRegister(),
            onAbout: () => _openLandingFromRegister(section: 'about'),
            onHowItWorks: () => _openLandingFromRegister(section: 'how'),
            onLogin: _showLoginFromRegister,
          );
        case AuthMode.verifyOtp:
          return VerifyEmailScreen(
            subtitle:
                'Enter the verification code sent to $_verificationEmail.',
            form: Form(key: _formKey, child: _buildOtpForm()),
            onHome: () => _openLandingFromRegister(),
            onAbout: () => _openLandingFromRegister(section: 'about'),
            onHowItWorks: () => _openLandingFromRegister(section: 'how'),
            onLogin: _showLoginFromRegister,
          );
        case AuthMode.verifyResetOtp:
          return VerifyResetCodeScreen(
            subtitle: 'Enter the password reset code sent to $_resetEmail.',
            form: Form(key: _formKey, child: _buildResetOtpForm()),
            onHome: () => _openLandingFromRegister(),
            onAbout: () => _openLandingFromRegister(section: 'about'),
            onHowItWorks: () => _openLandingFromRegister(section: 'how'),
            onLogin: _showLoginFromRegister,
          );
        case AuthMode.newPassword:
          return NewPasswordScreen(
            form: Form(key: _formKey, child: _buildNewPasswordForm()),
            onHome: () => _openLandingFromRegister(),
            onAbout: () => _openLandingFromRegister(section: 'about'),
            onHowItWorks: () => _openLandingFromRegister(section: 'how'),
            onLogin: _showLoginFromRegister,
          );
        case AuthMode.login:
          break;
      }
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: _isMobilePlatform
            ? MobileColors.surface
            : kIsWeb
            ? WebColors.surface
            : AppColors.surface,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white24),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),

                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 125,
                    height: 85,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 12),

                  _buildHeading(),

                  const SizedBox(height: 24),

                  if (_mode == AuthMode.login) _buildLoginForm(),

                  if (_mode == AuthMode.register) _buildRegisterForm(),

                  if (_mode == AuthMode.forgotPassword)
                    _buildForgotPasswordForm(),

                  if (_mode == AuthMode.verifyOtp) _buildOtpForm(),

                  if (_mode == AuthMode.verifyResetOtp) _buildResetOtpForm(),

                  if (_mode == AuthMode.newPassword) _buildNewPasswordForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebAuthPage() {
    final viewport = MediaQuery.sizeOf(context);
    final compact = viewport.width < 760;
    final veryNarrow = viewport.width < 420;
    final title = switch (_mode) {
      AuthMode.login => 'Log in',
      AuthMode.register => 'Create account',
      AuthMode.forgotPassword => 'Forgot password?',
      AuthMode.verifyOtp => 'Verify your email',
      AuthMode.verifyResetOtp => 'Verify reset code',
      AuthMode.newPassword => 'Create new password',
    };
    final subtitle = switch (_mode) {
      AuthMode.login => 'Enter your details to continue.',
      AuthMode.register => 'Create an account to get started.',
      AuthMode.forgotPassword => 'Enter your email to request a reset code.',
      AuthMode.verifyOtp => 'Enter the code sent to $_verificationEmail.',
      AuthMode.verifyResetOtp =>
        'Enter the password reset code sent to your email.',
      AuthMode.newPassword => 'Choose a new password for your account.',
    };
    final form = switch (_mode) {
      AuthMode.login => _buildLoginForm(),
      AuthMode.register => _buildRegisterForm(),
      AuthMode.forgotPassword => _buildForgotPasswordForm(),
      AuthMode.verifyOtp => _buildOtpForm(),
      AuthMode.verifyResetOtp => _buildResetOtpForm(),
      AuthMode.newPassword => _buildNewPasswordForm(),
    };

    final brandPanel = Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 24 : 56,
        compact ? 58 : 48,
        compact ? 24 : 56,
        compact ? 36 : 48,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF103E78), Color(0xFF102B76), Color(0xFF294B9A)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 520 : 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: compact ? (veryNarrow ? 210 : 260) : 310,
                height: compact ? (veryNarrow ? 145 : 180) : 240,
                fit: BoxFit.contain,
              ),
              SizedBox(height: compact ? 16 : 30),
              Text(
                _mode == AuthMode.register ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  height: 1.12,
                  fontWeight: FontWeight.bold,
                ).copyWith(fontSize: compact ? (veryNarrow ? 32 : 38) : 48),
              ),
              SizedBox(height: compact ? 10 : 18),
              Text(
                _mode == AuthMode.register
                    ? 'Sign up to get started.'
                    : 'Log in to continue to your account.',
                style: const TextStyle(
                  color: Color(0xFFD4DFF6),
                  fontSize: 18,
                  height: 1.6,
                ).copyWith(fontSize: compact ? 15 : 18),
              ),
            ],
          ),
        ),
      ),
    );

    final formPanel = Container(
      color: const Color(0xFF101B40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: compact
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    veryNarrow ? 20 : 28,
                    72,
                    veryNarrow ? 20 : 28,
                    32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: _buildWebAuthFormContent(title, subtitle, form),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(56, 72, 56, 32),
                  child: Form(
                    key: _formKey,
                    child: _buildWebAuthFormContent(title, subtitle, form),
                  ),
                ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF101B40),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: compact
                  ? SingleChildScrollView(
                      primary: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [brandPanel, formPanel],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(flex: 1, child: brandPanel),
                        Expanded(flex: 1, child: formPanel),
                      ],
                    ),
            ),
            Positioned(
              top: 12,
              left: 16,
              child: TextButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebAuthFormContent(String title, String subtitle, Widget form) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: WebColors.muted, fontSize: 15),
        ),
        const SizedBox(height: 32),
        form,
      ],
    );
  }

  // ============================================
  // FULL-SCREEN REGISTRATION PAGE
  // ============================================

  Widget _buildRegisterPage() {
    return MobileSignupScreen(
      formKey: _formKey,
      usernameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmController,
      usernameFocusNode: _nameFocusNode,
      emailFocusNode: _registerEmailFocusNode,
      passwordFocusNode: _registerPasswordFocusNode,
      confirmPasswordFocusNode: _confirmPasswordFocusNode,
      hidePassword: _hidePassword,
      hideConfirmPassword: _hideConfirm,
      acceptedTerms: _acceptedTerms,
      isLoading: _isLoading,
      onTogglePassword: () => setState(() => _hidePassword = !_hidePassword),
      onToggleConfirmPassword: () =>
          setState(() => _hideConfirm = !_hideConfirm),
      onTermsChanged: (value) =>
          setState(() => _acceptedTerms = value ?? false),
      onTermsTap: () => showTermsDialog(context),
      onCreateAccount: _register,
      onLogin: _showLoginFromRegister,
      onHome: () => _openLandingFromRegister(),
      onAbout: () => _openLandingFromRegister(section: 'about'),
      onHowItWorks: () => _openLandingFromRegister(section: 'how'),
    );
  }

  void _openLandingFromRegister({String? section}) {
    Navigator.of(context, rootNavigator: true).pop();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => LandingScreen(initialSection: section),
      ),
    );
  }

  void _showLoginFromRegister() {
    if (widget.resetFromProfile) {
      Navigator.of(context, rootNavigator: true).pop();
    } else if (_isMobilePlatform && widget.returnToLoginOnSignup) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    } else if (kIsWeb &&
        widget.initialMode != AuthMode.login &&
        !widget.webPage) {
      Navigator.of(context, rootNavigator: true).pop();
    } else if (_isMobilePlatform && widget.initialMode != AuthMode.login) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      _changeMode(AuthMode.login);
    }
  }

  // ============================================
  // SCREEN HEADING
  // ============================================

  Widget _buildHeading() {
    String title;
    String description;

    switch (_mode) {
      case AuthMode.login:
        title = kIsWeb ? 'Welcome Back' : 'Login to TilapiaSize';
        description = kIsWeb
            ? 'Login to continue to your account.'
            : 'Access your account to grade and review records.';
        break;

      case AuthMode.register:
        title = 'Create an Account';
        description = 'Join TilapiaSize and start grading your tilapia.';
        break;

      case AuthMode.forgotPassword:
        title = 'Forgot Password?';
        description = 'Enter your email address to request a password reset.';
        break;

      case AuthMode.verifyOtp:
        title = 'Verify Your Email';
        description = 'Enter the six-digit verification code for:';
        break;

      case AuthMode.verifyResetOtp:
        title = 'Verify Reset Code';
        description =
            'Enter the six-digit password reset code sent to your email.';
        break;

      case AuthMode.newPassword:
        title = 'Create New Password';
        description = 'Enter and confirm your new TilapiaSize password.';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(color: _authMutedColor, fontSize: 14, height: 1.5),
        ),

        if (_mode == AuthMode.verifyOtp) ...[
          const SizedBox(height: 6),
          Text(
            _verificationEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _authAccentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================
  // LOGIN FORM
  // ============================================

  Widget _buildLoginForm() {
    return Column(
      children: [
        _inputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          focusNode: _mobilePageStyle ? _registerEmailFocusNode : null,
          textInputAction: _mobilePageStyle ? TextInputAction.done : null,
          onFieldSubmitted: _mobilePageStyle
              ? (_) => FocusScope.of(context).unfocus()
              : null,
        ),

        const SizedBox(height: 12),

        _inputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          hidden: _hidePassword,
          onVisibility: () {
            setState(() => _hidePassword = !_hidePassword);
          },
        ),

        const SizedBox(height: 6),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => _changeMode(AuthMode.forgotPassword),
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: _authAccentColor),
            ),
          ),
        ),

        const SizedBox(height: 14),

        _mainButton('Login', _login),

        const SizedBox(height: 12),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: _authMutedColor),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => _changeMode(AuthMode.register),
              child: Text(
                widget.webPage ? 'Sign up' : 'Register',
                style: TextStyle(color: _authAccentColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // REGISTRATION FORM
  // ============================================

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _inputField(
          controller: _nameController,
          label: _mobileRegisterStyle ? 'Username' : 'Full Name',
          icon: Icons.person_outline,
          focusNode: _mobileRegisterStyle ? _nameFocusNode : null,
          textInputAction: _mobileRegisterStyle ? TextInputAction.next : null,
          textCapitalization: _mobileRegisterStyle
              ? TextCapitalization.words
              : TextCapitalization.none,
          onFieldSubmitted: _mobileRegisterStyle
              ? (_) => _registerEmailFocusNode.requestFocus()
              : null,
        ),

        const SizedBox(height: 12),

        _inputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          focusNode: _mobileRegisterStyle ? _registerEmailFocusNode : null,
          textInputAction: _mobileRegisterStyle ? TextInputAction.next : null,
          onFieldSubmitted: _mobileRegisterStyle
              ? (_) => _registerPasswordFocusNode.requestFocus()
              : null,
        ),

        const SizedBox(height: 12),

        _inputField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          hidden: _hidePassword,
          focusNode: _mobileRegisterStyle ? _registerPasswordFocusNode : null,
          textInputAction: _mobileRegisterStyle ? TextInputAction.next : null,
          onFieldSubmitted: _mobileRegisterStyle
              ? (_) => _confirmPasswordFocusNode.requestFocus()
              : null,
          onVisibility: () {
            setState(() => _hidePassword = !_hidePassword);
          },
        ),

        const SizedBox(height: 12),

        _inputField(
          controller: _confirmController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isPassword: true,
          hidden: _hideConfirm,
          focusNode: _mobileRegisterStyle ? _confirmPasswordFocusNode : null,
          textInputAction: _mobileRegisterStyle ? TextInputAction.done : null,
          onFieldSubmitted: _mobileRegisterStyle
              ? (_) => _confirmPasswordFocusNode.unfocus()
              : null,
          onVisibility: () {
            setState(() => _hideConfirm = !_hideConfirm);
          },
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Checkbox(
              value: _acceptedTerms,
              activeColor: _mobileRegisterStyle
                  ? _registerNavy
                  : (_isMobilePlatform
                        ? MobileColors.accent
                        : kIsWeb
                        ? WebColors.accent
                        : AppColors.accent),
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
            ),

            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'I agree to the ',
                    style: TextStyle(
                      color: _mobileRegisterStyle ? _registerInk : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  InkWell(
                    onTap: () => showTermsDialog(context),
                    child: Text(
                      'Terms and Conditions',
                      style: TextStyle(
                        color: _mobileRegisterStyle
                            ? _registerNavy
                            : (_isMobilePlatform
                                  ? MobileColors.accent
                                  : kIsWeb
                                  ? WebColors.accent
                                  : AppColors.mint),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _mainButton(
          _mobileRegisterStyle ? 'Create account' : 'Create Account',
          _register,
        ),

        const SizedBox(height: 12),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                color: _mobileRegisterStyle
                    ? const Color(0xFF657390)
                    : (_isMobilePlatform
                          ? const Color(0xFF657390)
                          : kIsWeb
                          ? WebColors.muted
                          : AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : _mobileRegisterStyle
                  ? _showLoginFromRegister
                  : () => _changeMode(AuthMode.login),
              child: const Text(
                'Login',
                style: TextStyle(color: _registerNavy),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // REGISTRATION OTP FORM
  // ============================================

  Widget _buildOtpForm() {
    final expired = _otpSecondsLeft == 0;
    final locked = _failedAttempts >= _maximumAttempts;

    return Column(
      children: [
        Icon(Icons.mark_email_read_outlined, color: _authAccentColor, size: 50),

        const SizedBox(height: 16),

        _buildOtpCountdown(),

        const SizedBox(height: 20),

        _buildOtpInput(
          enabled: !expired && !locked,
          label: 'Verification Code',
        ),

        const SizedBox(height: 8),

        Text(
          'Attempts remaining: '
          '${_maximumAttempts - _failedAttempts}',
          style: TextStyle(color: _authMutedColor, fontSize: 13),
        ),

        const SizedBox(height: 20),

        _mainButton('Verify Email', _verifyOtp, enabled: !expired && !locked),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _isLoading || _resendSecondsLeft > 0 ? null : _resendOtp,
          child: Text(
            _resendSecondsLeft > 0
                ? 'Resend Code in ${_formatTime(_resendSecondsLeft)}'
                : 'Resend Code',
            style: TextStyle(
              color: _resendSecondsLeft > 0
                  ? _authMutedColor
                  : _authAccentColor,
            ),
          ),
        ),

        TextButton.icon(
          onPressed: _isLoading ? null : () => _changeMode(AuthMode.register),
          icon: Icon(Icons.arrow_back, color: _authMutedColor, size: 18),
          label: Text(
            'Back to Registration',
            style: TextStyle(color: _authMutedColor),
          ),
        ),
      ],
    );
  }

  // ============================================
  // FORGOT PASSWORD EMAIL FORM
  // ============================================

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        _inputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          focusNode: _mobilePageStyle ? _registerEmailFocusNode : null,
          textInputAction: _mobilePageStyle ? TextInputAction.done : null,
          onFieldSubmitted: _mobilePageStyle
              ? (_) => FocusScope.of(context).unfocus()
              : null,
        ),

        const SizedBox(height: 20),

        _mainButton('Request Password Reset', _forgotPassword),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  if (widget.resetFromProfile ||
                      (_isMobilePlatform &&
                          widget.initialMode != AuthMode.login)) {
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    _changeMode(AuthMode.login);
                  }
                },
          icon: Icon(Icons.arrow_back, color: _authAccentColor, size: 18),
          label: Text(
            widget.resetFromProfile ? 'Back to Profile' : 'Back to Login',
            style: TextStyle(color: _authAccentColor),
          ),
        ),
      ],
    );
  }

  // ============================================
  // PASSWORD RESET OTP FORM
  // ============================================

  Widget _buildResetOtpForm() {
    final expired = _otpSecondsLeft == 0;
    final locked = _resetFailedAttempts >= _maximumAttempts;

    return Column(
      children: [
        Icon(
          Icons.mark_email_unread_outlined,
          color: _authAccentColor,
          size: 50,
        ),

        if (!_mobilePageStyle) ...[
          const SizedBox(height: 16),
          Text(
            _resetEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _authAccentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter the verification code sent to your email.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _authMutedColor, fontSize: 14),
          ),
        ],

        const SizedBox(height: 20),

        _buildOtpCountdown(),

        const SizedBox(height: 20),

        _buildOtpInput(
          enabled: !expired && !locked,
          label: 'Reset Verification Code',
        ),

        const SizedBox(height: 12),

        Text(
          'Attempts remaining: '
          '${_maximumAttempts - _resetFailedAttempts}',
          style: TextStyle(color: _authMutedColor, fontSize: 13),
        ),

        const SizedBox(height: 20),

        _mainButton(
          'Verify Reset Code',
          _verifyResetOtp,
          enabled: !expired && !locked,
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: _isLoading || _resendSecondsLeft > 0
              ? null
              : _resendPasswordResetOtp,
          child: Text(
            _resendSecondsLeft > 0
                ? 'Resend Code in ${_formatTime(_resendSecondsLeft)}'
                : 'Resend Code',
            style: TextStyle(
              color: _resendSecondsLeft > 0
                  ? _authMutedColor
                  : _authAccentColor,
            ),
          ),
        ),

        TextButton.icon(
          onPressed: _isLoading
              ? null
              : () => _changeMode(AuthMode.forgotPassword),
          icon: Icon(Icons.arrow_back, color: _authMutedColor, size: 18),
          label: Text(
            'Back to Forgot Password',
            style: TextStyle(color: _authMutedColor),
          ),
        ),
      ],
    );
  }

  // ============================================
  // NEW PASSWORD FORM
  // ============================================

  Widget _buildNewPasswordForm() {
    return Column(
      children: [
        Icon(Icons.lock_reset_outlined, color: _authAccentColor, size: 50),

        if (!_mobilePageStyle) ...[
          const SizedBox(height: 16),
          Text(
            'Choose a strong new password for your TilapiaSize account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _authMutedColor, fontSize: 14),
          ),
        ],

        const SizedBox(height: 24),

        _inputField(
          controller: _newPasswordController,
          label: 'New Password',
          icon: Icons.lock_outline,
          isPassword: true,
          hidden: _hidePassword,
          focusNode: _mobilePageStyle ? _registerPasswordFocusNode : null,
          textInputAction: _mobilePageStyle ? TextInputAction.next : null,
          onFieldSubmitted: _mobilePageStyle
              ? (_) => _confirmPasswordFocusNode.requestFocus()
              : null,
          onVisibility: () {
            setState(() => _hidePassword = !_hidePassword);
          },
        ),

        const SizedBox(height: 14),

        _inputField(
          controller: _confirmNewPasswordController,
          label: 'Confirm New Password',
          icon: Icons.lock_outline,
          isPassword: true,
          hidden: _hideConfirm,
          focusNode: _mobilePageStyle ? _confirmPasswordFocusNode : null,
          textInputAction: _mobilePageStyle ? TextInputAction.done : null,
          onFieldSubmitted: _mobilePageStyle
              ? (_) => _confirmPasswordFocusNode.unfocus()
              : null,
          onVisibility: () {
            setState(() => _hideConfirm = !_hideConfirm);
          },
        ),

        const SizedBox(height: 24),

        _mainButton('Reset Password', _resetPassword),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: _isLoading
              ? null
              : () {
                  _resetToken = '';
                  _newPasswordController.clear();
                  _confirmNewPasswordController.clear();
                  _changeMode(AuthMode.forgotPassword);
                },
          icon: Icon(Icons.arrow_back, color: _authMutedColor, size: 18),
          label: Text('Start Again', style: TextStyle(color: _authMutedColor)),
        ),
      ],
    );
  }

  // ============================================
  // SHARED OTP COUNTDOWN
  // ============================================

  Widget _buildOtpCountdown() {
    final expired = _otpSecondsLeft == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _mobilePageStyle
            ? const Color(0xFFF3F6FC)
            : (_isMobilePlatform
                  ? MobileColors.accent.withValues(alpha: 0.12)
                  : kIsWeb
                  ? WebColors.accent.withValues(alpha: 0.12)
                  : AppColors.accent.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expired
              ? Colors.redAccent
              : _mobilePageStyle
              ? const Color(0xFFDCE3F0)
              : (_isMobilePlatform
                    ? MobileColors.accent
                    : kIsWeb
                    ? WebColors.accent
                    : AppColors.accent),
        ),
      ),
      child: Column(
        children: [
          Text(
            'CODE EXPIRES IN',
            style: TextStyle(
              color: _authMutedColor,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _formatTime(_otpSecondsLeft),
            style: TextStyle(
              color: expired ? Colors.redAccent : _authAccentColor,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            expired
                ? 'Your OTP has expired.'
                : 'Your code is valid for 2 minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _authMutedColor, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SHARED OTP INPUT
  // ============================================

  Widget _buildOtpInput({required bool enabled, required String label}) {
    final mobilePage = _mobilePageStyle;

    return TextFormField(
      controller: _otpController,
      enabled: enabled && !_isLoading,
      keyboardType: TextInputType.number,
      textInputAction: mobilePage ? TextInputAction.done : null,
      onFieldSubmitted: mobilePage
          ? (_) => FocusScope.of(context).unfocus()
          : null,
      textAlign: TextAlign.center,
      maxLength: 6,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: TextStyle(
        color: mobilePage ? _registerInk : Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
        letterSpacing: 8,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '000000',
        counterText: '',
        filled: true,
        fillColor: mobilePage
            ? const Color(0xFFF3F6FC)
            : Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mobilePage ? 18 : 14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mobilePage ? 18 : 14),
          borderSide: BorderSide(
            color: mobilePage ? const Color(0xFFDCE3F0) : Colors.white24,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mobilePage ? 18 : 14),
          borderSide: BorderSide(
            color: mobilePage
                ? _registerNavy
                : (_isMobilePlatform
                      ? MobileColors.accent
                      : kIsWeb
                      ? WebColors.accent
                      : AppColors.mint),
            width: 2,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.length != 6) {
          return 'Please enter a six-digit OTP';
        }

        return null;
      },
    );
  }

  // ============================================
  // REUSABLE BUTTON
  // ============================================

  Widget _mainButton(
    String title,
    VoidCallback onPressed, {
    bool enabled = true,
  }) {
    final registerStyle = _mobileFormStyle;

    return SizedBox(
      width: double.infinity,
      height: registerStyle ? 56 : 48,
      child: ElevatedButton(
        onPressed: enabled && !_isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: registerStyle || _isMobilePlatform
              ? _registerNavy
              : kIsWeb
              ? (widget.webPage ? const Color(0xFF24499A) : WebColors.accent)
              : AppColors.mint,
          foregroundColor: registerStyle || _isMobilePlatform
              ? Colors.white
              : kIsWeb
              ? Colors.white
              : AppColors.background,
          shape: registerStyle
              ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
              : const StadiumBorder(),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ============================================
  // REUSABLE INPUT FIELD
  // ============================================

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool hidden = false,
    VoidCallback? onVisibility,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    final registerStyle = _mobileFormStyle;
    final suffixIcon = isPassword
        ? IconButton(
            onPressed: onVisibility,
            icon: Icon(
              hidden
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: registerStyle ? const Color(0xFF657390) : null,
            ),
          )
        : null;
    final decoration = registerStyle
        ? InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFF657390)),
            floatingLabelStyle: const TextStyle(
              color: _registerNavy,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: _registerNavy),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF3F6FC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFDCE3F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: _registerNavy, width: 2),
            ),
          )
        : InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: isPassword && hidden,
      style: TextStyle(color: registerStyle ? _registerInk : Colors.white),
      decoration: decoration,
      validator: (value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) {
          return 'Please enter $label';
        }

        if (label == 'Email' &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
          return 'Enter a valid email address';
        }

        if ((label == 'Password' && _mode == AuthMode.register ||
                label == 'New Password') &&
            text.length < 8) {
          return 'Use at least 8 characters';
        }

        if (label == 'Confirm Password' && text != _passwordController.text) {
          return 'Passwords do not match';
        }

        if (label == 'Confirm New Password' &&
            text != _newPasswordController.text) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }
}
