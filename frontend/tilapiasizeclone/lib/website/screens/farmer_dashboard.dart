import 'package:flutter/material.dart';

import '../../mobile/screens/guest/landing_screen.dart';
import '../../shared/widgets/page_entrance.dart';
import '../../services/api_service.dart';
import '../../theme/web_colors.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'my_batches_screen.dart';
import 'profile_screen.dart';
import '../widgets/web_sidebar.dart';
import '../widgets/web_upload_dialog.dart';

class WebFarmerDashboard extends StatefulWidget {
  const WebFarmerDashboard({super.key, required this.account});

  final Map<String, dynamic> account;

  @override
  State<WebFarmerDashboard> createState() => _WebFarmerDashboardState();
}

class _WebFarmerDashboardState extends State<WebFarmerDashboard> {
  static const _titles = ['Dashboard', 'My Batches', 'History', 'Profile'];
  int _tab = 0;

  void _select(int index) {
    if (_tab == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = index);
  }

  Future<void> _openUpload() => showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const WebUploadDialog(),
  );

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: WebColors.surface,
        title: const Text('Log out?'),
        content: const Text(
          'You will need to log in again to see your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LandingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compactSidebar = constraints.maxWidth <= 900;
      return Scaffold(
        backgroundColor: WebColors.background,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071D58), Color(0xFF12338A), Color(0xFF25479B)],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                WebSidebar(
                  compact: compactSidebar,
                  selectedIndex: _tab,
                  onNavigate: _select,
                  onUpload: _openUpload,
                ),
                Expanded(
                  child: Column(
                    children: [
                      _header(),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1064),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                constraints.maxWidth <= 600 ? 18 : 32,
                                12,
                                constraints.maxWidth <= 600 ? 18 : 32,
                                24,
                              ),
                              child: PageEntrance(
                                key: ValueKey('website-tab-$_tab'),
                                showLogoLoader: true,
                                loaderColor: WebColors.accent,
                                loaderBackgroundColor: WebColors.background,
                                child: SizedBox.expand(
                                  child: switch (_tab) {
                                    0 => WebDashboardScreen(
                                      onSeeAll: () => _select(1),
                                    ),
                                    1 => const WebMyBatchesScreen(),
                                    2 => const WebHistoryScreen(),
                                    _ => WebProfileScreen(
                                      account: widget.account,
                                      onLogout: _logout,
                                    ),
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Widget _header() => Container(
    height: 76,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: .10)),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            _titles[_tab],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Open profile',
          onPressed: () => _select(3),
          icon: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WebColors.card,
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
