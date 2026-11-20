import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../theme/mobile_colors.dart';
import '../../../shared/widgets/page_entrance.dart';
import '../../widgets/navbar.dart';
import '../../widgets/landing_sections.dart';
import '../auth/auth_dialog.dart';
import '../../widgets/terms_dialog.dart';
import '../../../website/screens/auth/login.dart';
import '../../../website/screens/auth/signup.dart';

// Main public landing page.
class LandingScreen extends StatefulWidget {
  final String? initialSection;

  const LandingScreen({super.key, this.initialSection});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Keys identify the sections for navigation.
  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _howKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final sectionKey = switch (widget.initialSection) {
      'about' => _aboutKey,
      'how' => _howKey,
      _ => null,
    };
    if (sectionKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final target = sectionKey.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(
            target,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.08,
          );
        }
      });
    }
  }

  // Scrolls smoothly to a selected section.
  void _scrollTo(GlobalKey key) {
    final drawerOpen = _scaffoldKey.currentState?.isDrawerOpen ?? false;

    if (drawerOpen) {
      Navigator.of(context).pop();
    }

    // Wait until the drawer has closed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final target = key.currentContext;

      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.08,
        );
      }
    });
  }

  // Opens Login / Register.
  void _openLogin() {
    final drawerOpen = _scaffoldKey.currentState?.isDrawerOpen ?? false;

    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    if (mobile) {
      if (drawerOpen) Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          showAuthDialog(context);
        }
      });
      return;
    }

    if (kIsWeb) {
      if (drawerOpen) Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const WebLoginScreen()));
      return;
    }

    if (drawerOpen) {
      Navigator.of(context).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAuthDialog(context);
        }
      });
    } else {
      showAuthDialog(context);
    }
  }

  void _openSignup() {
    final drawerOpen = _scaffoldKey.currentState?.isDrawerOpen ?? false;
    if (drawerOpen) Navigator.of(context).pop();

    if (kIsWeb) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const WebSignupScreen()));
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showAuthDialog(
          context,
          initialMode: AuthMode.register,
          returnToLoginOnSignup: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Keep native phones on the reference mobile theme, including landscape.
    final isNativeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final wide = screenWidth >= 800 && !isNativeMobile;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MobileColors.background,

      // Hamburger drawer for mobile screens.
      drawer: wide ? null : _mobileDrawer(),

      body: PageEntrance(
        showLogoLoader: true,
        loaderColor: const Color(0xFF8FD3FF),
        loaderBackgroundColor: const Color(0xFF0B246C),
        child: Stack(
          children: [
            // Use the same blue gradient palette as the mobile landing page.
            Positioned.fill(
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0B246C), Color(0xFF3055AA)],
                  ),
                ),
              ),
            ),

            // Scrollable landing page content.
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero section.
                    KeyedSubtree(
                      key: _homeKey,
                      child: LandingSections.hero(
                        wide: wide,
                        onStart: _openSignup,
                        onHow: () => _scrollTo(_howKey),
                      ),
                    ),

                    // About section.
                    KeyedSubtree(
                      key: _aboutKey,
                      child: LandingSections.about(wide: wide),
                    ),

                    // Four-step grading instructions.
                    KeyedSubtree(
                      key: _howKey,
                      child: LandingSections.howItWorks(mobile: !wide),
                    ),

                    // Get Started banner.
                    LandingSections.callToAction(
                      _openSignup,
                      onLogin: _openLogin,
                      mobile: !wide,
                    ),

                    // Footer with Terms link.
                    LandingSections.footer(
                      () => showTermsDialog(context),
                      mobile: !wide,
                    ),
                  ],
                ),
              ),
            ),

            // Floating navbar above the content.
            Positioned(
              top: wide ? MediaQuery.paddingOf(context).top + 10 : 0,
              left: wide ? 16 : 0,
              right: wide ? 16 : 0,
              child: Container(
                color: wide ? null : const Color(0xFF071A4D),
                padding: EdgeInsets.only(
                  top: wide ? 0 : MediaQuery.paddingOf(context).top,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: GuestNavbar(
                      wide: wide,
                      onHome: () => _scrollTo(_homeKey),
                      onAbout: () => _scrollTo(_aboutKey),
                      onHow: () => _scrollTo(_howKey),
                      onLogin: _openLogin,
                      onMenu: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mobile navigation drawer.
  Widget _mobileDrawer() {
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.78)
          .clamp(240.0, 320.0)
          .toDouble(),
      backgroundColor: const Color(0xFF0B1730),
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close menu',
                icon: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 128,
                height: 82,
                fit: BoxFit.contain,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white24, height: 1),
            ),
            const SizedBox(height: 8),
            _drawerLink('Home', Icons.home_outlined, () => _scrollTo(_homeKey)),
            _drawerLink(
              'About',
              Icons.info_outline,
              () => _scrollTo(_aboutKey),
            ),
            _drawerLink(
              'How it works',
              Icons.help_outline,
              () => _scrollTo(_howKey),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Divider(color: Colors.white24, height: 1),
            ),
            _drawerLink('Login', Icons.login, _openLogin),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Keep drawer rows visually consistent with the login screen.
  Widget _drawerLink(String title, IconData icon, VoidCallback action) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18),
      leading: Icon(icon, color: const Color(0xFFDCE6FF), size: 19),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: action,
    );
  }
}
