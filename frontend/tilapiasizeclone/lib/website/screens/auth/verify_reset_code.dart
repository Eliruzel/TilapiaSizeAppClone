import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

class WebVerifyResetCodeScreen extends StatelessWidget {
  const WebVerifyResetCodeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthDialog(webPage: true, initialMode: AuthMode.verifyResetOtp);
}
