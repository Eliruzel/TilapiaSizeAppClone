import 'package:flutter/material.dart';

import 'app.dart';
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore a valid saved login on web and native mobile. The stored token's
  // expiry determines when the user must sign in again.
  final restoredAccount = await ApiService.restoreSession();

  runApp(TilapiaSizeApp(restoredAccount: restoredAccount));
}
