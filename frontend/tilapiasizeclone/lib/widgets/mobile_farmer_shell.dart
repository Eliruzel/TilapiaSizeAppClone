import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/auth/login.dart';
import '../screens/auth/auth_dialog.dart';
import '../theme/app_colors.dart';
import 'page_entrance.dart';
import '../services/api_service.dart';
import '../screens/farmer/profile_form.dart';

/// Mobile screens with connected profile and UI-only grading workflows.
class MobileFarmerShell extends StatefulWidget {
  const MobileFarmerShell({super.key, this.account = const {}});
  final Map<String, dynamic> account;

  @override
  State<MobileFarmerShell> createState() => _MobileFarmerShellState();
}

class _MobileFarmerShellState extends State<MobileFarmerShell> {
  int _tab = 0;
  late Map<String, dynamic> _account = Map.of(widget.account);
  bool _profileLoading = false;
  String? _profileError;
  OverlayEntry? _notice;
  Timer? _noticeTimer;

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
          color: AppColors.card,
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.mint),
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
                  icon: const Icon(Icons.close, color: AppColors.muted),
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

  String _batchFilter = 'All';
  String _activityFilter = 'All';
  String _sort = 'Newest first';
  String _period = 'Last 7 days';
  final _batchSearch = TextEditingController();
  final _historySearch = TextEditingController();
  static const _titles = ['Dashboard', 'My Batches', 'History', 'Profile'];

  String _value(String key) => _account[key]?.toString().trim() ?? '';

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _notice?.remove();
    _batchSearch.dispose();
    _historySearch.dispose();
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
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.mint,
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.background
                  : AppColors.muted,
            ),
          ),
          labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _tab,
          onDestinationSelected: _select,
          animationDuration: Duration.zero,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.layers_outlined),
              label: 'My Batches',
            ),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_icon.png',
                      width: 62,
                      height: 46,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _titles[_tab],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageEntrance(
                  key: ValueKey('mobile-tab-$_tab'),
                  showLogoLoader: true,
                  child: switch (_tab) {
                    0 => _dashboard(),
                    1 => _batches(),
                    2 => _history(),
                    _ => _profile(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboard() => LayoutBuilder(
    builder: (context, space) {
      // Keep the overview fixed; use a compact arrangement on short screens.
      final short = space.maxHeight < 560;
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _metric('Active', Icons.layers_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _metric('Completed', Icons.lock_outline)),
            ],
          ),
          const SizedBox(height: 10),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title('Grade your tilapia', size: 18),
                if (!short) ...[
                  const SizedBox(height: 6),
                  _caption('Choose photos or open the camera to start.'),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _button(
                        'Upload Images',
                        Icons.file_upload_outlined,
                        _upload,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _button(
                        'Live Camera',
                        Icons.camera_alt_outlined,
                        _camera,
                        filled: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: _title('Recent Batches', size: 17)),
                      TextButton(
                        onPressed: () => _select(1),
                        child: const Text(
                          'View all',
                          style: TextStyle(color: AppColors.mint),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!short)
                            const Icon(
                              Icons.layers_outlined,
                              size: 32,
                              color: AppColors.mint,
                            ),
                          const SizedBox(height: 6),
                          _title('No batches to display', size: 15),
                          if (!short) ...[
                            const SizedBox(height: 6),
                            _caption(
                              'Saved batches will appear here.',
                              center: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
      return _fitOverview(space, content, minimumHeight: 430);
    },
  );

  // Scale only in exceptionally short viewports (e.g. landscape). Normal
  // portrait layouts use their actual available space without scrolling.
  Widget _fitOverview(
    BoxConstraints space,
    Widget child, {
    required double minimumHeight,
  }) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final needed = minimumHeight * scale.clamp(1, 2);
    if (space.maxHeight >= needed) return child;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topCenter,
      child: SizedBox(width: space.maxWidth, height: needed, child: child),
    );
  }

  Widget _metric(String label, IconData icon) => _card(
    padding: 12,
    child: Row(
      children: [
        Icon(icon, color: AppColors.mint, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _caption(label),
              const Text(
                '—',
                style: TextStyle(
                  color: AppColors.mint,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _batches() => ListView(
    key: const PageStorageKey('mobile-batches-scroll'),
    padding: EdgeInsets.zero,
    children: [
      _caption('Find and review your saved grading results.'),
      const SizedBox(height: 16),
      _search(_batchSearch, 'Search batches'),
      const SizedBox(height: 12),
      _chips(
        ['All', 'Active', 'Needs Review', 'Completed'],
        _batchFilter,
        (value) => setState(() => _batchFilter = value),
      ),
      const SizedBox(height: 12),
      _dropdown(_sort, [
        'Newest first',
        'Oldest first',
        'Name A–Z',
      ], (value) => setState(() => _sort = value)),
      const SizedBox(height: 10),
      _caption('Active includes batches that need review.'),
      const SizedBox(height: 24),
      _empty(
        Icons.layers_outlined,
        'No batches to display',
        'Batch storage is not connected yet. No sample records are shown.',
      ),
      if (_batchFilter != 'All' || _batchSearch.text.isNotEmpty)
        TextButton(
          onPressed: () => setState(() {
            _batchFilter = 'All';
            _batchSearch.clear();
          }),
          child: const Text('Clear filters'),
        ),
    ],
  );

  Widget _history() => ListView(
    key: const PageStorageKey('mobile-history-scroll'),
    padding: EdgeInsets.zero,
    children: [
      _caption('Track your batch activity over time.'),
      const SizedBox(height: 16),
      _search(_historySearch, 'Search activity'),
      const SizedBox(height: 12),
      _dropdown(_period, [
        'Last 7 days',
        'Last 30 days',
        'All time',
      ], (value) => setState(() => _period = value)),
      const SizedBox(height: 12),
      _chips(
        ['All', 'Created', 'Reviewed', 'Completed', 'Deleted'],
        _activityFilter,
        (value) => setState(() => _activityFilter = value),
      ),
      const SizedBox(height: 24),
      _empty(
        Icons.history,
        'No activity to display',
        'History is not connected yet. Real batch activity will appear here.',
      ),
      const SizedBox(height: 16),
      _caption(
        'Completed batches are permanently locked. Deleted batches will retain an activity entry only.',
      ),
    ],
  );

  Widget _profile() => LayoutBuilder(
    builder: (context, space) {
      if (_profileLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.mint),
        );
      }
      if (_profileError != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _caption(_profileError!, center: true),
              TextButton(
                onPressed: ApiService.hasSession ? _loadProfile : _logout,
                child: Text(
                  ApiService.hasSession ? 'Retry' : 'Return to login',
                ),
              ),
            ],
          ),
        );
      }
      final name = _value('full_name');
      final initial = name.isEmpty ? null : name.characters.first.toUpperCase();
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.card,
                      foregroundColor: AppColors.mint,
                      child: initial == null
                          ? const Icon(Icons.person_outline)
                          : Text(initial),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Your profile' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _value('email').isEmpty
                                ? 'Email unavailable'
                                : _value('email'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detail('Farm name', _value('farm_name')),
                const SizedBox(height: 10),
                _detail('Location', _value('farm_location')),
                const SizedBox(height: 16),
                _button('Edit Profile', Icons.edit_outlined, _editProfile),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _button(
            'Change Password',
            Icons.lock_outline,
            _changePassword,
            filled: false,
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFA28D),
              minimumSize: const Size(0, 48),
            ),
          ),
          _caption('Completed batch records stay locked.', center: true),
        ],
      );
      return _fitOverview(space, content, minimumHeight: 430);
    },
  );

  Widget _detail(String label, String value) => Row(
    children: [
      SizedBox(width: 86, child: _caption(label)),
      Expanded(
        child: Text(
          value.isEmpty ? 'Not set' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ],
  );

  void _upload() => _sheet('Upload Images', [
    _caption('Select tilapia photos to begin grading.'),
    const SizedBox(height: 24),
    _empty(
      Icons.add_photo_alternate_outlined,
      'No images selected',
      'Photo selection will be connected in the next implementation step.',
    ),
    const SizedBox(height: 20),
    _button('Choose Images', Icons.photo_library_outlined, null, filled: false),
    const SizedBox(height: 12),
    _button('Analyze Images', Icons.auto_awesome_outlined, null),
    const SizedBox(height: 12),
    _caption(
      'Analysis is unavailable until a grading model is connected. No results will be generated here.',
    ),
  ]);

  void _camera() => _sheet('Live Camera', [
    _empty(
      Icons.camera_alt_outlined,
      'Camera not connected',
      'The camera preview and capture controls will be connected next.',
    ),
    const SizedBox(height: 20),
    _button('Capture photo', Icons.camera, null),
    const SizedBox(height: 12),
    _caption('No camera permission is requested by this UI-only screen.'),
  ]);

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
      backgroundColor: AppColors.surface,
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
        backgroundColor: AppColors.surface,
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
        backgroundColor: AppColors.surface,
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
                        icon: const Icon(Icons.close, color: AppColors.muted),
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

  Widget _search(TextEditingController controller, String hint) => TextField(
    controller: controller,
    onChanged: (_) => setState(() {}),
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search, color: AppColors.mint),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: () => setState(controller.clear),
              icon: const Icon(Icons.close),
            ),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  Widget _chips(
    List<String> values,
    String selected,
    ValueChanged<String> onChanged,
  ) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children: values
        .map(
          (value) => ChoiceChip(
            selected: value == selected,
            label: Text(value),
            showCheckmark: false,
            onSelected: (_) => onChanged(value),
            selectedColor: AppColors.mint,
            labelStyle: TextStyle(
              color: value == selected ? AppColors.background : Colors.white,
            ),
            backgroundColor: AppColors.surface,
          ),
        )
        .toList(),
  );

  Widget _dropdown(
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => _card(
    padding: 8,
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        style: const TextStyle(color: Colors.white),
        items: options
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    ),
  );

  Widget _empty(IconData icon, String title, String message) => _card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.mint, size: 38),
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
      color: AppColors.surface.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.mint.withValues(alpha: .18)),
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
    style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
  );

  Widget _button(
    String text,
    IconData icon,
    VoidCallback? onPressed, {
    bool filled = true,
  }) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: filled ? AppColors.mint : Colors.transparent,
      foregroundColor: filled ? AppColors.background : AppColors.mint,
      disabledBackgroundColor: AppColors.card,
      disabledForegroundColor: AppColors.muted.withValues(alpha: .5),
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      side: filled ? BorderSide.none : const BorderSide(color: AppColors.mint),
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
