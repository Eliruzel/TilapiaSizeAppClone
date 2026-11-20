import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/web_colors.dart';
import '../services/image_picker.dart';
import '../services/image_selection.dart';

class WebProfileScreen extends StatefulWidget {
  const WebProfileScreen({
    super.key,
    required this.account,
    required this.onLogout,
  });

  final Map<String, dynamic> account;
  final VoidCallback onLogout;

  @override
  State<WebProfileScreen> createState() => _WebProfileScreenState();
}

class _WebProfileScreenState extends State<WebProfileScreen> {
  late Map<String, dynamic> _account = Map.of(widget.account);
  late final _name = TextEditingController(text: _value('full_name'));
  late final _farmName = TextEditingController(text: _value('farm_name'));
  late final _location = TextEditingController(text: _value('farm_location'));
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _savingProfile = false;
  bool _savingPassword = false;
  bool _showPasswords = false;
  PickedWebImage? _profileImage;
  bool _pickingProfileImage = false;
  String? _profileMessage;
  String? _passwordMessage;
  bool _profileMessageError = false;
  bool _passwordMessageError = false;

  String _value(String key) => _account[key]?.toString().trim() ?? '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _farmName.dispose();
    _location.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!ApiService.hasSession) return;
    setState(() => _loading = true);
    try {
      final result = await ApiService.getProfile();
      if (!mounted) return;
      setState(() {
        _account = result;
        _name.text = _value('full_name');
        _farmName.text = _value('farm_name');
        _location.text = _value('farm_location');
      });
    } on ApiException catch (error) {
      if (mounted) _profileNotice(error.message, isError: true);
    } catch (_) {
      if (mounted) {
        _profileNotice(
          'Could not load your profile. Try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickProfileImage() async {
    if (_pickingProfileImage) return;
    setState(() => _pickingProfileImage = true);
    try {
      final picked = await pickWebImage();
      if (!mounted || picked == null) return;
      setState(() => _profileImage = picked);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Profile photo preview updated.')),
        );
    } finally {
      if (mounted) setState(() => _pickingProfileImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_savingProfile) return;
    if (_name.text.trim().isEmpty) {
      _profileNotice('Enter your full name.', isError: true);
      return;
    }
    setState(() {
      _savingProfile = true;
      _profileMessage = null;
    });
    try {
      final result = await ApiService.updateProfile(
        fullName: _name.text,
        farmName: _farmName.text,
        farmLocation: _location.text,
      );
      if (!mounted) return;
      setState(() {
        _account = result;
        _name.text = _value('full_name');
        _farmName.text = _value('farm_name');
        _location.text = _value('farm_location');
      });
      _profileNotice('Profile updated.');
    } on ApiException catch (error) {
      _profileNotice(error.message, isError: true);
    } catch (_) {
      _profileNotice('Unable to save your profile right now.', isError: true);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (_savingPassword) return;
    final current = _currentPassword.text;
    final next = _newPassword.text;
    if (current.isEmpty) {
      _passwordNotice('Enter your current password.', isError: true);
      return;
    }
    if (next.length < 8) {
      _passwordNotice(
        'Use at least 8 characters for the new password.',
        isError: true,
      );
      return;
    }
    if (next == current) {
      _passwordNotice(
        'Choose a password different from your current one.',
        isError: true,
      );
      return;
    }
    if (next != _confirmPassword.text) {
      _passwordNotice('The new passwords do not match.', isError: true);
      return;
    }
    setState(() {
      _savingPassword = true;
      _passwordMessage = null;
    });
    try {
      await ApiService.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      if (!mounted) return;
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      _passwordNotice('Password updated.');
    } on ApiException catch (error) {
      _passwordNotice(error.message, isError: true);
    } catch (_) {
      _passwordNotice(
        'Unable to update your password right now.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  void _profileNotice(String message, {bool isError = false}) => setState(() {
    _profileMessage = message;
    _profileMessageError = isError;
  });

  void _passwordNotice(String message, {bool isError = false}) => setState(() {
    _passwordMessage = message;
    _passwordMessageError = isError;
  });

  @override
  Widget build(BuildContext context) {
    final fullName = _value('full_name');
    final initial = fullName.isEmpty
        ? null
        : fullName.characters.first.toUpperCase();
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 900;
        final identity = Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: WebColors.card,
                  foregroundColor: Colors.white,
                  backgroundImage: _profileImage == null
                      ? null
                      : MemoryImage(_profileImage!.bytes),
                  child: _profileImage != null
                      ? null
                      : initial == null
                      ? const Icon(Icons.person_outline, size: 44)
                      : Text(initial, style: const TextStyle(fontSize: 34)),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: IconButton.filled(
                    tooltip: 'Choose profile photo',
                    onPressed: _pickingProfileImage ? null : _pickProfileImage,
                    icon: _pickingProfileImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.edit_outlined, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: WebColors.accent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fullName.isEmpty ? 'Your profile' : fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _value('email').isEmpty ? 'Email unavailable' : _value('email'),
              style: const TextStyle(color: WebColors.muted, fontSize: 13),
            ),
          ],
        );
        final fullNameCard = _card('Account details', [
          _input(_name, 'Full name'),
          _input(_farmName, 'Farm name (optional)'),
          _input(_location, 'Farm location (optional)'),
          if (_profileMessage != null)
            _message(_profileMessage!, _profileMessageError),
          const SizedBox(height: 8),
          _actionButton(
            _savingProfile ? 'Saving…' : 'Save profile',
            onPressed: _savingProfile ? null : _saveProfile,
          ),
        ]);
        final passwordCard = _card('Change password', [
          _input(_currentPassword, 'Current password', password: true),
          _input(_newPassword, 'New password', password: true),
          _input(_confirmPassword, 'Confirm new password', password: true),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _showPasswords,
            onChanged: (value) =>
                setState(() => _showPasswords = value ?? false),
            activeColor: WebColors.accent,
            title: const Text(
              'Show passwords',
              style: TextStyle(color: WebColors.muted, fontSize: 13),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_passwordMessage != null)
            _message(_passwordMessage!, _passwordMessageError),
          const SizedBox(height: 8),
          _actionButton(
            _savingPassword ? 'Updating…' : 'Update password',
            onPressed: _savingPassword ? null : _savePassword,
          ),
        ]);

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 20),
                child: identity,
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                ),
              if (twoColumns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: fullNameCard),
                    const SizedBox(width: 20),
                    Expanded(child: passwordCard),
                  ],
                )
              else ...[
                fullNameCard,
                const SizedBox(height: 16),
                passwordCard,
              ],
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: .2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _card('Delete account', [
                const Text(
                  'Deleting your account permanently removes your profile, batches, and history. This action cannot be undone.',
                  style: TextStyle(
                    color: WebColors.muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete my account'),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Account deletion is not available yet.',
                  style: TextStyle(color: Color(0xFFFF9D9D), fontSize: 12),
                ),
              ], danger: true),
            ],
          ),
        );
      },
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool password = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      obscureText: password && !_showPasswords,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: WebColors.muted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _card(String title, List<Widget> children, {bool danger = false}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: danger
                ? const Color(0x73FF7878)
                : Colors.white.withValues(alpha: .14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                color: danger ? const Color(0xFFFF9D9D) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _actionButton(String label, {required VoidCallback? onPressed}) =>
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: WebColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(label),
        ),
      );

  Widget _message(String text, bool error) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: error ? const Color(0xFFFF9D9D) : WebColors.completed,
        fontSize: 12,
      ),
    ),
  );
}
