import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../../screens/farmer/farmer_dashboard.dart';
import '../guest/landing_screen.dart';
import './auth_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const navy = Color(0xFF102B76);
  static const ink = Color(0xFF14254B);
  static const headerNavy = Color(0xFF071A4D);
  static const drawerNavy = Color(0xFF0B1730);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.login(
        email: _email.text.trim().toLowerCase(),
        password: _password.text,
      );

      if (!mounted) return;

      final account = Map<String, dynamic>.from(result['user'] as Map);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => FarmerDashboard(account: account),
        ),
        (_) => false,
      );
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Unable to log in. Check your connection and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openAuth(AuthMode mode) async {
    FocusScope.of(context).unfocus();

    await showDialog<void>(
      context: context,
      builder: (_) => AuthDialog(initialMode: mode, email: _email.text.trim()),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF657390)),
      floatingLabelStyle: const TextStyle(
        color: navy,
        fontWeight: FontWeight.w600,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8994AA)),
      prefixIcon: Icon(icon, color: navy, size: 21),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF3F6FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCE3F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: navy, width: 2),
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

  @override
  Widget build(BuildContext context) {
    // Read this above Scaffold because Scaffold adjusts viewInsets for its body.
    final keyboardIsOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: headerNavy,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true, // body shrinks above the keyboard
        drawer: _navigationDrawer(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _loginHeader(),
              Expanded(
                child: ColoredBox(
                  color: navy, // shows behind the white panel's rounded corners
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(child: _hero(keyboardIsOpen)),
                      SliverFillRemaining(
                        hasScrollBody: false, // fills when tall, scrolls when short
                        child: _formPanel(keyboardIsOpen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero(bool keyboardIsOpen) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, keyboardIsOpen ? 8 : 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo collapses smoothly when the keyboard opens.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: keyboardIsOpen
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          height: 120,
                          width: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
          ),
          Text(
            'Welcome Back',
            style: TextStyle(
              color: Colors.white,
              fontSize: keyboardIsOpen ? 26 : 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Log in to continue to your account.',
            style: TextStyle(
              color: Color(0xFFDCE6FF),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formPanel(bool keyboardIsOpen) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, keyboardIsOpen ? 20 : 32, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _email,
                      enabled: !_loading,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      autocorrect: false,
                      style: const TextStyle(color: ink),
                      decoration: _decoration(
                        label: 'Email address',
                        hint: 'you@example.com',
                        icon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _password,
                      enabled: !_loading,
                      obscureText: _hidePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _login(),
                      style: const TextStyle(color: ink),
                      decoration: _decoration(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          tooltip:
                              _hidePassword ? 'Show password' : 'Hide password',
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF657390),
                          ),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Enter your password.'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => _openAuth(AuthMode.forgotPassword),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 4),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFBA3545)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Color(0xFF657390)),
                        ),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => _openAuth(AuthMode.register),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginHeader() {
    return Container(
      height: 52,
      color: headerNavy,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Open menu',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
          ),
          Image.asset(
            'assets/images/app_icon.png',
            width: 38,
            height: 32,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _navigationDrawer() {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.78)
          .clamp(240.0, 320.0)
          .toDouble(),
      backgroundColor: drawerNavy,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close menu',
                icon: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 128,
                height: 82,
                fit: BoxFit.contain,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24, height: 1),
            ),
            const SizedBox(height: 8),
            _drawerItem('Home', Icons.home_outlined, () => _openLanding()),
            _drawerItem(
              'About',
              Icons.info_outline,
              () => _openLanding(section: 'about'),
            ),
            _drawerItem(
              'How it works',
              Icons.help_outline,
              () => _openLanding(section: 'how'),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerItem(
              'Login',
              Icons.login,
              () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: Icon(icon, color: const Color(0xFFDCE6FF), size: 19),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _openLanding({String? section}) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LandingScreen(initialSection: section),
      ),
    );
  }
}
