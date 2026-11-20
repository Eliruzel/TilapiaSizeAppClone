import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

class WebNewPasswordScreen extends StatelessWidget {
  const WebNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthDialog(webPage: true, initialMode: AuthMode.newPassword);
}
