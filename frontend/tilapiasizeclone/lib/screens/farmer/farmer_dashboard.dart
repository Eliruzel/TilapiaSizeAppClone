import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../shared/widgets/page_entrance.dart';

import './my_batches.dart';
import '../../widgets/farmer_page_layout.dart';
import '../../mobile/screens/farmer/farmer_dashboard.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key, this.account = const {}});
  final Map<String, dynamic> account;

  static const List<({String name, String date, String count, bool completed})>
  _batches = [];

  bool get _showCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // UI placeholders. Connect these in the next steps.
  void _openUpload() {}

  void _openCamera() {}

  void _openBatches(BuildContext context) {
    Navigator.of(context).push(_batchesRoute());
  }

  Route<void> _batchesRoute() => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, animation, secondaryAnimation) => const MyBatchesScreen(),
    // Keep the page switch immediate. Matching Hero tags animate the nav
    // icons between their dashboard and batches positions in both directions.
    transitionsBuilder: (_, animation, secondaryAnimation, child) => child,
  );

  @override
  Widget build(BuildContext context) {
    if (_showCamera) return MobileFarmerDashboard(account: account);
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: _mobileMenu(context),
      body: Stack(
        children: [
          // Reuse the guest page's existing background asset.
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.78),
                    AppColors.background.withValues(alpha: 0.96),
                    AppColors.background,
                  ],
                  stops: const [0, 0.38, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final desktop = constraints.maxWidth >= 1000;
                return FarmerPageLayout(
                  header: _navigation(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageEntrance(
                        key: const ValueKey('dashboard-summary'),
                        delay: const Duration(milliseconds: 200),
                        distance: 28,
                        child: _summary(),
                      ),
                      const SizedBox(height: 16),
                      if (desktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 8,
                              child: PageEntrance(
                                key: const ValueKey('desktop-batches'),
                                delay: const Duration(milliseconds: 360),
                                distance: 28,
                                child: _recentBatches(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: PageEntrance(
                                key: const ValueKey('desktop-grading'),
                                delay: const Duration(milliseconds: 480),
                                distance: 28,
                                child: _gradingStation(),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        PageEntrance(
                          key: const ValueKey('mobile-grading'),
                          delay: const Duration(milliseconds: 360),
                          distance: 28,
                          child: _gradingStation(),
                        ),
                        const SizedBox(height: 16),
                        PageEntrance(
                          key: const ValueKey('mobile-batches'),
                          delay: const Duration(milliseconds: 480),
                          distance: 28,
                          child: _recentBatches(context),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigation(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final expanded =
              constraints.maxWidth >= 1000 &&
              MediaQuery.textScalerOf(context).scale(16) <= 20;

          return Row(
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: expanded ? 100 : 72,
                height: 58,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  expanded ? 'Farmer Dashboard' : 'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: expanded ? 21 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (expanded) ...[
                _navItem('Dashboard', Icons.dashboard_outlined, selected: true),
                _navItem(
                  'My Batches',
                  Icons.layers_outlined,
                  onTap: () => _openBatches(context),
                ),
                _navItem('History', Icons.history),
                _navItem('Profile', Icons.person_outline),
              ] else
                IconButton(
                  tooltip: 'Open navigation',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _navItem(
    String title,
    IconData icon, {
    bool selected = false,
    VoidCallback? onTap,
  }) {
    final navIcon = Icon(icon, size: 20);
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: TextButton.icon(
        onPressed: onTap ?? () {},
        icon: title == 'Dashboard' || title == 'My Batches'
            ? Hero(tag: 'farmer-nav-$title', child: navIcon)
            : navIcon,
        label: Text(title),
        style: TextButton.styleFrom(
          foregroundColor: selected ? AppColors.background : Colors.white,
          backgroundColor: selected ? AppColors.mint : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _mobileMenu(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset('assets/images/app_icon.png', height: 90),
            const SizedBox(height: 24),
            for (final item in [
              (title: 'Dashboard', icon: Icons.dashboard_outlined),
              (title: 'My Batches', icon: Icons.layers_outlined),
              (title: 'History', icon: Icons.history),
              (title: 'Profile', icon: Icons.person_outline),
            ])
              ListTile(
                selected: item.title == 'Dashboard',
                selectedTileColor: AppColors.mint.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(item.icon, color: AppColors.mint),
                title: Text(
                  item.title,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  if (item.title == 'My Batches') {
                    navigator.push(_batchesRoute());
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _summary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final active = _statusCard(
          'Active Batches',
          _batches.where((batch) => !batch.completed).length.toString(),
          Icons.layers_outlined,
        );

        final completed = _statusCard(
          'Completed Batches',
          _batches.where((batch) => batch.completed).length.toString(),
          Icons.check_circle_outline,
        );

        // Stack on very narrow screens or with enlarged text.
        final largeText = MediaQuery.textScalerOf(context).scale(16) > 20;

        if (constraints.maxWidth < 340 || largeText) {
          return Column(
            children: [active, const SizedBox(height: 12), completed],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: active),
            const SizedBox(width: 16),
            Expanded(child: completed),
          ],
        );
      },
    );
  }

  Widget _statusCard(String label, String value, IconData icon) {
    return _GlassPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 280;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.mint, size: 28),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _count(value),
              ],
            );
          }

          return Row(
            children: [
              _iconTile(icon),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _count(value),
            ],
          );
        },
      ),
    );
  }

  Widget _count(String value) {
    return Text(
      value,
      style: const TextStyle(
        color: AppColors.mint,
        fontSize: 44,
        height: 1.1,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _recentBatches(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading('Recent Batches'),
          const SizedBox(height: 8),
          const Text(
            'Your latest grading batches and their status.',
            style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),

          if (_batches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.layers_outlined,
                    size: 52,
                    color: AppColors.mint.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No batches yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your saved grading batches will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final batch in _batches.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _batchRow(
                  name: batch.name,
                  date: batch.date,
                  count: batch.count,
                  completed: batch.completed,
                ),
              ),

          const SizedBox(height: 16),
          _actionButton(
            label: 'View all batches',
            icon: Icons.arrow_forward,
            onPressed: () => _openBatches(context),
            filled: false,
          ),
        ],
      ),
    );
  }

  Widget _batchRow({
    required String name,
    required String date,
    required String count,
    required bool completed,
  }) {
    return Container(
      width: double.infinity, // Makes every card fill the available width.
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                date,
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          );

          final fishCount = Text(
            '$count fish',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          );

          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [fishCount, _statusBadge(completed)],
                ),
              ],
            );
          }

          return Row(
            children: [
              const Icon(
                Icons.set_meal_outlined,
                color: AppColors.mint,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(child: title),
              const SizedBox(width: 16),
              fishCount,
              const SizedBox(width: 24),
              _statusBadge(completed),
            ],
          );
        },
      ),
    );
  }

  Widget _statusBadge(bool completed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFB9DAD0) : AppColors.mint,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        completed ? 'Completed' : 'Active',
        style: const TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _gradingStation() {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading('Grading Station'),
          const SizedBox(height: 8),
          const Text(
            'Determine tilapia size grade from images.',
            style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 68,
                color: AppColors.mint,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Start a new grading',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showCamera
                ? 'Upload fish images or use your camera.'
                : 'Upload fish images to grade tilapia size.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          _actionButton(
            label: 'Upload Images',
            icon: Icons.file_upload_outlined,
            onPressed: _openUpload,
          ),
          if (_showCamera) ...[
            const SizedBox(height: 12),
            _actionButton(
              label: 'Live Camera',
              icon: Icons.camera_alt_outlined,
              onPressed: _openCamera,
              filled: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _heading(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.mint, size: 38),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool filled = true,
  }) {
    final style = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: filled ? AppColors.mint : Colors.transparent,
      foregroundColor: filled ? AppColors.background : AppColors.mint,
      minimumSize: const Size(0, 50),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: StadiumBorder(
        side: BorderSide(color: filled ? Colors.transparent : AppColors.mint),
      ),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    );

    return ElevatedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 22),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}
