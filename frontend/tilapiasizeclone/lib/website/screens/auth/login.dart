import 'package:flutter/material.dart';

import '../../../mobile/screens/auth/auth_dialog.dart';

/// Full-page web login entry point.
class WebLoginScreen extends StatelessWidget {
  const WebLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const AuthDialog(webPage: true);
}
