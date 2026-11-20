import 'package:flutter/material.dart';

import '../../../theme/mobile_colors.dart';

class MobileHistoryScreen extends StatelessWidget {
  const MobileHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('mobile-history-scroll'),
    padding: const EdgeInsets.only(bottom: 12),
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .14)),
        ),
        child: const Column(
          children: [
            Icon(Icons.history, color: MobileColors.accent, size: 38),
            SizedBox(height: 14),
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
              'Your batch, grading, and profile activity will appear here, grouped by day with its time and related batch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MobileColors.muted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
