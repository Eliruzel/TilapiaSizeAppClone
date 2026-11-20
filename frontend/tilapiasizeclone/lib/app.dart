import 'package:flutter/material.dart';

import './mobile/screens/guest/landing_screen.dart';
import './screens/farmer/farmer_dashboard.dart';
import './theme/mobile_theme.dart';
import './theme/web_theme.dart';

import 'package:flutter/foundation.dart';

import './mobile/screens/auth/login.dart';
import './website/screens/farmer_dashboard.dart';

class TilapiaSizeApp extends StatelessWidget {
  final Map<String, dynamic>? restoredAccount;

  const TilapiaSizeApp({super.key, this.restoredAccount});

  @override
  Widget build(BuildContext context) {
    final isNativeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return MaterialApp(
      title: 'TilapiaSize',
      debugShowCheckedModeBanner: false,

      // Main app theme.
      theme: isNativeMobile ? MobileTheme.data : WebTheme.data,

      // Starting screen.
      home: isNativeMobile
          ? restoredAccount == null
                ? const LoginScreen()
                : FarmerDashboard(account: restoredAccount!)
          : kIsWeb && restoredAccount != null
          ? WebFarmerDashboard(account: restoredAccount!)
          : const LandingScreen(),
    );
  }
}
