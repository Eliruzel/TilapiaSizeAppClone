import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

class WebForgotPasswordScreen extends StatelessWidget {
  const WebForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthDialog(webPage: true, initialMode: AuthMode.forgotPassword);
}
