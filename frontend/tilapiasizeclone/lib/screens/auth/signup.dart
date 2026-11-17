import 'package:flutter/material.dart';

class MobileSignupScreen extends StatefulWidget {
  const MobileSignupScreen({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.usernameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.acceptedTerms,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onTermsChanged,
    required this.onTermsTap,
    required this.onCreateAccount,
    required this.onLogin,
    required this.onHome,
    required this.onAbout,
    required this.onHowItWorks,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode usernameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final bool acceptedTerms;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHowItWorks;

  @override
  State<MobileSignupScreen> createState() => _MobileSignupScreenState();
}

class _MobileSignupScreenState extends State<MobileSignupScreen> {
  static const _navy = Color(0xFF102B76);
  static const _headerNavy = Color(0xFF071A4D);
  static const _drawerNavy = Color(0xFF0B1730);
  static const _ink = Color(0xFF14254B);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  InputDecoration _decoration({required String label, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF657390)),
      floatingLabelStyle: const TextStyle(
        color: _navy,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: const Color(0xFFF3F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIcon: Icon(_iconFor(label), color: _navy, size: 21),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCE3F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _navy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFBA3545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFBA3545), width: 2),
      ),
      errorMaxLines: 2,
    );
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'Username':
        return Icons.person_outline_rounded;
      case 'Email':
        return Icons.mail_outline_rounded;
      default:
        return Icons.lock_outline_rounded;
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required TextInputAction action,
    required ValueChanged<String> onSubmitted,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: !widget.isLoading,
      keyboardType: keyboardType,
      textInputAction: action,
      textCapitalization: capitalization,
      autocorrect: false,
      enableSuggestions: !obscureText,
      obscureText: obscureText,
      style: const TextStyle(color: _ink),
      decoration: _decoration(label: label, suffix: suffix),
      onFieldSubmitted: onSubmitted,
      validator: validator,
    );
  }

  Widget _buildForm() {
    return AutofillGroup(
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _textField(
              controller: widget.usernameController,
              focusNode: widget.usernameFocusNode,
              label: 'Username',
              capitalization: TextCapitalization.words,
              action: TextInputAction.next,
              onSubmitted: (_) => widget.emailFocusNode.requestFocus(),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your username.'
                  : null,
            ),
            const SizedBox(height: 14),
            _textField(
              controller: widget.emailController,
              focusNode: widget.emailFocusNode,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              onSubmitted: (_) => widget.passwordFocusNode.requestFocus(),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _textField(
              controller: widget.passwordController,
              focusNode: widget.passwordFocusNode,
              label: 'Password',
              action: TextInputAction.next,
              obscureText: widget.hidePassword,
              onSubmitted: (_) => widget.confirmPasswordFocusNode.requestFocus(),
              suffix: IconButton(
                tooltip: widget.hidePassword ? 'Show password' : 'Hide password',
                onPressed: widget.onTogglePassword,
                icon: Icon(
                  widget.hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF657390),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a password.';
                }
                if (value.length < 8) return 'Use at least 8 characters.';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _textField(
              controller: widget.confirmPasswordController,
              focusNode: widget.confirmPasswordFocusNode,
              label: 'Confirm Password',
              action: TextInputAction.done,
              obscureText: widget.hideConfirmPassword,
              onSubmitted: (_) => widget.confirmPasswordFocusNode.unfocus(),
              suffix: IconButton(
                tooltip: widget.hideConfirmPassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: widget.onToggleConfirmPassword,
                icon: Icon(
                  widget.hideConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF657390),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirm your password.';
                }
                if (value != widget.passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: widget.acceptedTerms,
                  activeColor: _navy,
                  onChanged: widget.isLoading ? null : widget.onTermsChanged,
                ),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'I agree to the ',
                        style: TextStyle(color: _ink, fontSize: 13),
                      ),
                      InkWell(
                        onTap: widget.onTermsTap,
                        child: const Text(
                          'Terms and Conditions',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: widget.isLoading ? null : widget.onCreateAccount,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: Color(0xFF657390), fontSize: 13),
                ),
                TextButton(
                  onPressed: widget.isLoading ? null : widget.onLogin,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _closeDrawerThen(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  Widget _drawerItem(String label, IconData icon, VoidCallback action) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: const Color(0xFFDCE6FF), size: 19),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: () => _closeDrawerThen(action),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.78)
          .clamp(240.0, 320.0)
          .toDouble(),
      backgroundColor: _drawerNavy,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close menu',
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Image.asset(
              'assets/images/app_icon.png',
              width: 128,
              height: 82,
              fit: BoxFit.contain,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerItem('Home', Icons.home_outlined, widget.onHome),
            _drawerItem('About', Icons.info_outline, widget.onAbout),
            _drawerItem('How it works', Icons.help_outline, widget.onHowItWorks),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerItem('Login', Icons.login, widget.onLogin),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        scaffoldBackgroundColor: _headerNavy,
        colorScheme: ColorScheme.fromSeed(seedColor: _navy),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 52,
                color: _headerNavy,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      tooltip: 'Open menu',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 34,
                        height: 34,
                      ),
                      icon: const Icon(Icons.menu, color: Colors.white),
                    ),
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 38,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Container(
                color: _navy,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        height: 120,
                        width: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign up to get started.',
                      style: TextStyle(
                        color: Color(0xFFDCE6FF),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: _buildForm(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
