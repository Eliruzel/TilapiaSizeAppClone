import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.profile,
    this.passwordMode = false,
  });
  final Map<String, dynamic> profile;
  final bool passwordMode;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _first = TextEditingController(
    text: widget.passwordMode ? '' : widget.profile['full_name']?.toString(),
  );
  late final _second = TextEditingController(
    text: widget.passwordMode ? '' : widget.profile['farm_name']?.toString(),
  );
  late final _third = TextEditingController(
    text: widget.passwordMode
        ? ''
        : widget.profile['farm_location']?.toString(),
  );
  bool _busy = false;
  bool _visible = false;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _third.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      Map<String, dynamic> result;
      if (widget.passwordMode) {
        await ApiService.changePassword(
          currentPassword: _first.text,
          newPassword: _second.text,
        );
        result = {'password_updated': true};
      } else {
        result = await ApiService.updateProfile(
          fullName: _first.text,
          farmName: _second.text,
          farmLocation: _third.text,
        );
      }
      if (!mounted) return;
      setState(() => _busy = false);
      Navigator.of(context).pop(result);
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on ServerUnavailableException {
      if (mounted) {
        setState(
          () => _error =
              'Cannot reach the server. Check your connection and try again.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to save right now. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = widget.passwordMode;
    return PopScope(
      canPop: !_busy,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        password ? 'Change Password' : 'Edit Profile',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!password) ...[
                          Text(
                            'Email: ${widget.profile['email'] ?? ''}',
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _input(
                          _first,
                          password ? 'Current password' : 'Full name',
                          limit: password ? 256 : 120,
                          validate: (value) =>
                              (password ? value.isEmpty : value.trim().isEmpty)
                              ? 'This field is required.'
                              : null,
                        ),
                        if (password)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.pop(context, {
                                      'reset_password': true,
                                    }),
                              child: const Text('Forgot current password?'),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _input(
                          _second,
                          password ? 'New password' : 'Farm name (optional)',
                          limit: password ? 256 : 160,
                          validate: (value) {
                            if (!password) return null;
                            if (value.length < 8 || value.trim().isEmpty) {
                              return 'Use at least 8 characters.';
                            }
                            if (value == _first.text) {
                              return 'Choose a different password.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _input(
                          _third,
                          password
                              ? 'Confirm new password'
                              : 'Farm location (optional)',
                          limit: password ? 256 : 240,
                          validate: (value) => password && value != _second.text
                              ? 'Passwords do not match.'
                              : null,
                        ),
                        if (password)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _visible,
                            onChanged: _busy
                                ? null
                                : (value) => setState(() => _visible = value!),
                            title: const Text('Show passwords'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.background,
                            minimumSize: const Size(0, 48),
                          ),
                          child: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  password ? 'Update Password' : 'Save Changes',
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    required int limit,
    required String? Function(String) validate,
  }) => TextFormField(
    controller: controller,
    enabled: !_busy,
    maxLength: limit,
    obscureText: widget.passwordMode && !_visible,
    autocorrect: !widget.passwordMode,
    enableSuggestions: !widget.passwordMode,
    validator: (value) => validate(value ?? ''),
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      counterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
