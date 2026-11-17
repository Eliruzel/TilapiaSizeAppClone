import 'package:flutter/material.dart';

import 'mobile_auth_page.dart';

class VerifyResetCodeScreen extends StatelessWidget {
  const VerifyResetCodeScreen({
    super.key,
    required this.subtitle,
    required this.form,
    required this.onHome,
    required this.onAbout,
    required this.onHowItWorks,
    required this.onLogin,
  });

  final String subtitle;
  final Widget form;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHowItWorks;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => MobileAuthPage(
    title: 'Verify Reset Code',
    subtitle: subtitle,
    form: form,
    onHome: onHome,
    onAbout: onAbout,
    onHowItWorks: onHowItWorks,
    onLogin: onLogin,
  );
}
