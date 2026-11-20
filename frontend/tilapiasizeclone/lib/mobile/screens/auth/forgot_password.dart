import 'package:flutter/material.dart';

import './mobile_auth_page.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.form,
    required this.onHome,
    required this.onAbout,
    required this.onHowItWorks,
    required this.onLogin,
  });

  final Widget form;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHowItWorks;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => MobileAuthPage(
    title: 'Forgot Password?',
    subtitle: 'Enter your email to request a password reset.',
    form: form,
    onHome: onHome,
    onAbout: onAbout,
    onHowItWorks: onHowItWorks,
    onLogin: onLogin,
  );
}
