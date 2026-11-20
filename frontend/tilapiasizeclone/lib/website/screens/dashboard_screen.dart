import 'package:flutter/material.dart';

import '../../theme/web_colors.dart';

class WebDashboardScreen extends StatelessWidget {
  const WebDashboardScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      return SingleChildScrollView(
        padding: EdgeInsets.only(bottom: compact ? 18 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summary(compact),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent batches',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFF7FE0EA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _emptyBatches(),
          ],
        ),
      );
    },
  );

  Widget _summary(bool compact) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 14 : 20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: .16)),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Metric(
            icon: Icons.autorenew,
            value: '0',
            label: 'Active',
            color: WebColors.accent,
          ),
        ),
        _divider(),
        Expanded(
          child: _Metric(
            icon: Icons.check_circle_outline,
            value: '0',
            label: 'Complete',
            color: WebColors.completed,
          ),
        ),
        _divider(),
        Expanded(
          child: _Metric(
            icon: Icons.outlined_flag,
            value: '0',
            label: 'Need review',
            color: WebColors.review,
          ),
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    width: 1,
    height: 56,
    color: Colors.white.withValues(alpha: .18),
  );

  Widget _emptyBatches() => Container(
    constraints: const BoxConstraints(minHeight: 210),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.set_meal_outlined, color: Colors.white70, size: 38),
            SizedBox(height: 12),
            Text(
              'No batches yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Saved grading batches will appear here when available.',
              textAlign: TextAlign.center,
              style: TextStyle(color: WebColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
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
          style: const TextStyle(color: WebColors.muted, fontSize: 12),
        ),
      ),
    ],
  );
}
