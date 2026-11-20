import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

/// Full-page web signup entry point.
class WebSignupScreen extends StatelessWidget {
  const WebSignupScreen({super.key});

  @override
  Widget build(BuildContext context) => const AuthDialog(
    webPage: true,
    initialMode: AuthMode.register,
    returnToLoginOnSignup: true,
  );
}
