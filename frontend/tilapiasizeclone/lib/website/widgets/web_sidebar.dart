import 'package:flutter/material.dart';

import '../../theme/web_colors.dart';

class WebSidebar extends StatelessWidget {
  const WebSidebar({
    super.key,
    required this.compact,
    required this.selectedIndex,
    required this.onNavigate,
    required this.onUpload,
  });

  final bool compact;
  final int selectedIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onUpload;

  static const _destinations = [
    (label: 'Dashboard', icon: Icons.dashboard_outlined),
    (label: 'My Batches', icon: Icons.layers_outlined),
    (label: 'History', icon: Icons.history),
    (label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) => Container(
    width: compact ? 76 : 264,
    padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16, vertical: 22),
    decoration: const BoxDecoration(
      color: WebColors.background,
      border: Border(right: BorderSide(color: Colors.white12)),
    ),
    child: Column(
      children: [
        Image.asset(
          'assets/images/app_icon.png',
          width: compact ? 50 : 150,
          height: 56,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.file_upload_outlined, size: 20),
            label: compact
                ? const SizedBox.shrink()
                : const Text('Upload image'),
            style: FilledButton.styleFrom(
              backgroundColor: WebColors.accent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        for (var i = 0; i < _destinations.length; i++) ...[
          _navItem(context, i),
          const SizedBox(height: 4),
        ],
        const Spacer(),
        if (!compact)
          const Text(
            'Tilapia Size',
            style: TextStyle(color: WebColors.muted, fontSize: 12),
          ),
      ],
    ),
  );

  Widget _navItem(BuildContext context, int index) {
    final item = _destinations[index];
    final active = selectedIndex == index;
    return Tooltip(
      message: compact ? item.label : '',
      child: Material(
        color: active
            ? Colors.white.withValues(alpha: .14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onNavigate(index),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (!compact) const SizedBox(width: 14),
                Icon(
                  item.icon,
                  size: 21,
                  color: active ? WebColors.accent : Colors.white,
                ),
                if (!compact) ...[
                  const SizedBox(width: 14),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
