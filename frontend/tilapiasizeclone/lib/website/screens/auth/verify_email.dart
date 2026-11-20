import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

class WebVerifyEmailScreen extends StatelessWidget {
  const WebVerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthDialog(webPage: true, initialMode: AuthMode.verifyOtp);
}
