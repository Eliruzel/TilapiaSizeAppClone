import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../auth/login.dart';
import '../auth/auth_dialog.dart';
import '../../../services/api_service.dart';
import '../../../shared/widgets/page_entrance.dart';
import './profile_form.dart';
import './dashboard_screen.dart';
import './history_screen.dart';
import './my_batches_screen.dart';
import './profile_screen.dart';
import './camera_capture_screen.dart';
import '../../widgets/mobile_bottom_nav.dart';
import '../../../theme/mobile_colors.dart';

const _mobileBg = MobileColors.background;
const _mobileSurface = MobileColors.surface;
const _mobileCard = MobileColors.card;
const _mobileAccent = MobileColors.accent;
const _mobileMuted = MobileColors.muted;

/// Mobile screens with connected profile and UI-only grading workflows.
class MobileFarmerDashboard extends StatefulWidget {
  const MobileFarmerDashboard({super.key, this.account = const {}});
  final Map<String, dynamic> account;

  @override
  State<MobileFarmerDashboard> createState() => _MobileFarmerDashboardState();
}

typedef MobileFarmerShell = MobileFarmerDashboard;

class _MobileFarmerDashboardState extends State<MobileFarmerDashboard> {
  int _tab = 0;
  late Map<String, dynamic> _account = Map.of(widget.account);
  bool _profileLoading = false;
  String? _profileError;
  OverlayEntry? _notice;
  Timer? _noticeTimer;
  Uint8List? _capturedPhotoBytes;

  Future<void> _loadProfile() async {
    if (_profileLoading || !ApiService.hasSession) return;
    setState(() {
      _profileLoading = true;
      _profileError = null;
    });
    try {
      final data = await ApiService.getProfile();
      if (mounted) setState(() => _account = data);
    } on ApiException catch (error) {
      if (mounted) setState(() => _profileError = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _profileError =
              'Cannot load your profile. Check your connection and retry.',
        );
      }
    } finally {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  void _showSuccess(String message) {
    _noticeTimer?.cancel();
    _notice?.remove();
    _notice = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: _mobileCard,
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: _mobileAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  onPressed: () {
                    _noticeTimer?.cancel();
                    _notice?.remove();
                    _notice = null;
                  },
                  icon: const Icon(Icons.close, color: _mobileMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_notice!);
    _noticeTimer = Timer(const Duration(seconds: 4), () {
      _notice?.remove();
      _notice = null;
    });
  }

  static const _titles = ['Dashboard', 'My Batches', 'History', 'Profile'];

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _notice?.remove();
    super.dispose();
  }

  void _select(int index) {
    if (_tab == index) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _tab = index);
    if (index == 3) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mobileBg,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: MobileBottomNav(
        currentIndex: _tab,
        onDestinationSelected: _select,
        onAddPressed: _openCreateMenu,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_mobileBg, Color(0xFF0D2C78), Color(0xFF25479B)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: _mobileBg,
                  border: Border(bottom: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 76,
                      height: 52,
                    ),
                    Container(
                      width: 1,
                      height: 26,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: Colors.white30,
                    ),
                    Expanded(
                      child: Text(
                        _titles[_tab],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Profile',
                      onPressed: () => _select(3),
                      icon: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54, width: 2),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: PageEntrance(
                    key: ValueKey('mobile-tab-$_tab'),
                    showLogoLoader: true,
                    loaderColor: _mobileAccent,
                    loaderBackgroundColor: _mobileBg,
                    child: switch (_tab) {
                      0 => MobileDashboardScreen(
                        onSeeAllBatches: () => _select(1),
                      ),
                      1 => const MobileMyBatchesScreen(),
                      2 => const MobileHistoryScreen(),
                      _ => MobileProfileScreen(
                        account: _account,
                        isLoading: _profileLoading,
                        error: _profileError,
                        onRetry: _loadProfile,
                        onEditProfile: _editProfile,
                        onChangePassword: _changePassword,
                        onLogout: _logout,
                        onProfilePhotoTap: _profilePhotoUnavailable,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _profilePhotoUnavailable() => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Profile photo updates are not connected yet.'),
      ),
    );

  void _openCreateMenu() => _sheet('Start grading', [
    _caption('Choose how you want to add tilapia images.'),
    const SizedBox(height: 18),
    _button('Upload Images', Icons.file_upload_outlined, () {
      Navigator.of(context).pop();
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _upload();
      });
    }),
    const SizedBox(height: 10),
    _button('Live Camera', Icons.camera_alt_outlined, () {
      Navigator.of(context).pop();
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _camera();
      });
    }, filled: false),
  ]);

  void _upload() => _sheet('Upload Images', [
    _caption('Select tilapia photos to begin grading.'),
    const SizedBox(height: 24),
    if (_capturedPhotoBytes == null)
      _empty(
        Icons.add_photo_alternate_outlined,
        'No images selected',
        'Capture a photo with Live Camera or choose an image from your gallery.',
      )
    else
      _capturedPhotoCard(),
    const SizedBox(height: 20),
    _button('Choose Images', Icons.photo_library_outlined, null, filled: false),
    const SizedBox(height: 12),
    _button('Analyze Images', Icons.auto_awesome_outlined, null),
    const SizedBox(height: 12),
    _caption(
      'Analysis will be available when the trained grading model is connected. No results are generated yet.',
    ),
  ]);

  Future<void> _camera() async {
    final bytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(builder: (_) => const CameraCaptureScreen()),
    );
    if (bytes == null || !mounted) return;
    setState(() => _capturedPhotoBytes = bytes);
    _showSuccess('Photo captured with the Tilapia detection overlay.');
  }

  Widget _capturedPhotoCard() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _mobileCard,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            _capturedPhotoBytes!,
            height: 210,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox(
              height: 210,
              child: Center(
                child: Icon(Icons.broken_image_outlined, color: Colors.white70),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Captured photo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _capturedPhotoBytes = null),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _editProfile() => _openProfileForm(password: false);
  Future<void> _changePassword() => _openProfileForm(password: true);

  Future<void> _openProfileForm({required bool password}) async {
    if (!ApiService.hasSession) {
      setState(
        () => _profileError = 'Please log in again to update your profile.',
      );
      return;
    }
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: _mobileSurface,
      builder: (_) => ProfileForm(profile: _account, passwordMode: password),
    );
    if (!mounted) return;
    if (result?['reset_password'] == true) {
      final reset = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AuthDialog(
          resetFromProfile: true,
          email: _account['email']?.toString() ?? '',
        ),
      );
      if (!mounted) return;
      if (reset == true) _showSuccess('Password updated successfully.');
      return;
    }
    if (result != null) {
      if (!password) setState(() => _account = result);
      _showSuccess(
        password
            ? 'Password updated successfully.'
            : 'Profile updated successfully.',
      );
    } else if (!ApiService.hasSession) {
      setState(
        () => _profileError = 'Your session has expired. Please log in again.',
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: _mobileSurface,
        title: const Text('Log out?'),
        content: const Text('Return to the guest page on this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await ApiService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _sheet(String title, List<Widget> children) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: _mobileSurface,
        showDragHandle: true,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _title(title)),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close, color: _mobileMuted),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _empty(IconData icon, String title, String message) => _card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: _mobileAccent, size: 38),
          const SizedBox(height: 14),
          _title(title, size: 17),
          const SizedBox(height: 8),
          _caption(message, center: true),
        ],
      ),
    ),
  );

  Widget _card({required Widget child, double padding = 16}) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .14)),
    ),
    child: child,
  );

  Widget _title(String text, {double size = 21}) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: size,
    ),
  );

  Widget _caption(String text, {bool center = false}) => Text(
    text,
    textAlign: center ? TextAlign.center : TextAlign.start,
    style: const TextStyle(color: _mobileMuted, fontSize: 13, height: 1.35),
  );

  Widget _button(
    String text,
    IconData icon,
    VoidCallback? onPressed, {
    bool filled = true,
  }) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: filled ? _mobileAccent : Colors.transparent,
      foregroundColor: filled ? _mobileBg : _mobileAccent,
      disabledBackgroundColor: _mobileCard,
      disabledForegroundColor: _mobileMuted.withValues(alpha: .5),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      side: filled ? BorderSide.none : const BorderSide(color: _mobileAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
