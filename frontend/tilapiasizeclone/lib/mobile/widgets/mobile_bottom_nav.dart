import 'package:flutter/material.dart';

import '../../theme/mobile_colors.dart';

/// Reusable bottom navigation for the mobile farmer area.
class MobileBottomNav extends StatelessWidget {
  const MobileBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onAddPressed;

  static const _navy = MobileColors.surface;
  static const _muted = Color(0xFF9CB2DF);
  static const _cyan = MobileColors.accent;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SizedBox(
      height: 76 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 68 + bottomInset,
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: _navy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  _item(0, Icons.dashboard_outlined, 'Dashboard'),
                  _item(1, Icons.layers_outlined, 'My Batches'),
                  const SizedBox(width: 64),
                  _item(2, Icons.history, 'History'),
                  _item(3, Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ),
          Positioned(
            top: -2,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              elevation: 8,
              shadowColor: Colors.black45,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onAddPressed,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _navy, width: 5),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF3CC6D3), Color(0xFF1F8FA0)],
                    ),
                  ),
                  child: const Icon(Icons.add, size: 30, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = currentIndex == index;
    final color = selected ? Colors.white : _muted;
    return Expanded(
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 4,
                child: selected
                    ? const DecoratedBox(
                        decoration: BoxDecoration(
                          color: _cyan,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 4, height: 4),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
