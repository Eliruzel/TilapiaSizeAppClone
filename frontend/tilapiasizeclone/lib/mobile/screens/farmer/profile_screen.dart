import 'package:flutter/material.dart';

import '../../../theme/mobile_colors.dart';

class MobileProfileScreen extends StatelessWidget {
  const MobileProfileScreen({
    super.key,
    required this.account,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onLogout,
    required this.onProfilePhotoTap,
  });

  final Map<String, dynamic> account;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final VoidCallback onProfilePhotoTap;

  String _value(String key) => account[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: MobileColors.accent),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _caption(error!, center: true),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final name = _value('full_name');
    final initial = name.isEmpty ? null : name.characters.first.toUpperCase();
    return ListView(
      key: const PageStorageKey('mobile-profile-scroll'),
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: MobileColors.card,
                    foregroundColor: MobileColors.accent,
                    child: initial == null
                        ? const Icon(Icons.person_outline, size: 38)
                        : Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Material(
                      color: MobileColors.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onProfilePhotoTap,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: MobileColors.background,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _title(name.isEmpty ? 'Your profile' : name, size: 19),
              const SizedBox(height: 3),
              _caption(
                _value('email').isEmpty ? 'Email unavailable' : _value('email'),
                center: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _title('Username', size: 16),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: name,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Username not set',
                  hintStyle: const TextStyle(color: MobileColors.muted),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: .08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: .16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _caption(
                'Your account currently stores a full name rather than a separate username.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _title('Farm details', size: 16),
              const SizedBox(height: 14),
              _detail('Farm name', _value('farm_name')),
              const SizedBox(height: 10),
              _detail('Location', _value('farm_location')),
              const SizedBox(height: 16),
              _button('Edit Profile', Icons.edit_outlined, onEditProfile),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _title('Change password', size: 16),
              const SizedBox(height: 6),
              _caption(
                'Update your password securely using your current password.',
              ),
              const SizedBox(height: 12),
              _button(
                'Update password',
                Icons.lock_outline,
                onChangePassword,
                filled: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFA28D),
            minimumSize: const Size(0, 48),
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Delete account',
                style: TextStyle(
                  color: Color(0xFFFF9D9D),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _caption(
                'Account deletion will permanently remove your profile, batches, and history. This action is not available yet.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete my account'),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
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
    style: const TextStyle(color: MobileColors.muted, fontSize: 13, height: 1.35),
  );

  Widget _button(
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool filled = true,
  }) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: filled ? MobileColors.accent : Colors.transparent,
      foregroundColor: filled ? MobileColors.background : MobileColors.accent,
      minimumSize: const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      side: filled ? BorderSide.none : const BorderSide(color: MobileColors.accent),
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
