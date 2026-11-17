import 'package:flutter/material.dart';
import 'screens/guest/landing_screen.dart';
import 'screens/farmer/farmer_dashboard.dart';
import 'theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'screens/auth/login.dart';


class TilapiaSizeApp extends StatelessWidget {
  final Map<String, dynamic>? restoredAccount;

  const TilapiaSizeApp({super.key, this.restoredAccount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TilapiaSize',
      debugShowCheckedModeBanner: false,

      // Main app theme.
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
      ),

      // Starting screen.
      home: !kIsWeb &&
              (defaultTargetPlatform == TargetPlatform.android ||
                  defaultTargetPlatform == TargetPlatform.iOS)
          ? restoredAccount == null
              ? const LoginScreen()
              : FarmerDashboard(account: restoredAccount!)
          : const LandingScreen(),
    );
  }
}
