import 'package:flutter/material.dart';

import '../../theme/web_colors.dart';

class WebHistoryScreen extends StatelessWidget {
  const WebHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 28),
    child: Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: WebColors.accent, size: 38),
            SizedBox(height: 12),
            Text(
              'No history yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your account activity will appear here, grouped by day with its time and related batch.',
              textAlign: TextAlign.center,
              style: TextStyle(color: WebColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
