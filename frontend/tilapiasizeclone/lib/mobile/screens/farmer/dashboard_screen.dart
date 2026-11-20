import 'package:flutter/material.dart';

import '../../../theme/mobile_colors.dart';

class MobileDashboardScreen extends StatelessWidget {
  const MobileDashboardScreen({super.key, required this.onSeeAllBatches});

  final VoidCallback onSeeAllBatches;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, space) {
      final compact = space.maxHeight < 480;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summary(compact),
          SizedBox(height: compact ? 14 : 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent batches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAllBatches,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: MobileColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: _emptyRecent(compact)),
        ],
      );
    },
  );

  Widget _summary(bool compact) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: compact ? 12 : 18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: Colors.white.withValues(alpha: .16)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: _Metric(
            value: '0',
            label: 'Active',
            icon: Icons.autorenew,
            color: MobileColors.accent,
          ),
        ),
        _divider(),
        const Expanded(
          child: _Metric(
            value: '0',
            label: 'Complete',
            icon: Icons.check_circle_outline,
            color: Color(0xFF5FD3A0),
          ),
        ),
        _divider(),
        const Expanded(
          child: _Metric(
            value: '0',
            label: 'Need review',
            icon: Icons.outlined_flag,
            color: Color(0xFFFFC857),
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 48,
    color: Colors.white.withValues(alpha: .18),
  );

  Widget _emptyRecent(bool compact) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(compact ? 12 : 16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.set_meal_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No batches yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Your saved grading batches will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MobileColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap + to start grading.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MobileColors.muted, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 21),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 2),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
            color: MobileColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
