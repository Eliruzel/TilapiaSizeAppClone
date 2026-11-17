
import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Navigation bar for the guest landing page.
class GuestNavbar extends StatelessWidget {
  final bool wide;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onHow;
  final VoidCallback onLogin;
  final VoidCallback onMenu;

  const GuestNavbar({
    super.key,
    required this.wide,
    required this.onHome,
    required this.onAbout,
    required this.onHow,
    required this.onLogin,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Container(
        height: 52,
        color: const Color(0xFF071A4D),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onMenu,
              tooltip: 'Open menu',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            ),
            Image.asset(
              'assets/images/app_icon.png',
              width: 38,
              height: 32,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),

      // Creates the frosted-glass effect.
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 16,
          sigmaY: 16,
        ),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(
              alpha: 0.78,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white30,
            ),
          ),
          child: Row(
            children: [
              if (!wide)
                IconButton(
                  onPressed: onMenu,
                  tooltip: 'Open menu',
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                )
              else
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 118,
                  height: 60,
                  fit: BoxFit.contain,
                ),

              const Spacer(),

              // Full navbar on larger screens.
              if (wide) ...[
                _navLink('Home', onHome),
                _navLink('About', onAbout),
                _navLink('How It Works', onHow),
                const SizedBox(width: 12),

                ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]

              else
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 90,
                  height: 60,
                  fit: BoxFit.contain,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable navbar links.
  Widget _navLink(
    String title,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
