import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Reusable glass-style container.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),

      // Blurs the background behind the panel.
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Transparent dark-green background.
            color: AppColors.card.withValues(alpha: 0.65),

            // Rounded corners.
            borderRadius: BorderRadius.circular(radius),

            // Subtle border around the panel.
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
            ),

            // Soft shadow.
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),

          // Content placed inside the panel.
          child: child,
        ),
      ),
    );
  }
}
