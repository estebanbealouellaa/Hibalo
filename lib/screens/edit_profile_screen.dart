import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/account_service.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_avatar.dart';
import 'forgot_password_screen.dart';

/// Edit profile (Figma 608:5354): username and avatar always; a new email or password only after the current password is confirmed.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    this.currentPhotoUrl,
    this.account,
    this.onAccountDeleted,
  });

  final String currentUsername;
  final String? currentPhotoUrl;

  /// For tests; Firebase when null.
  final AccountActions? account;

  /// After Delete account (goes to Sign Up).
  final VoidCallback? onAccountDeleted;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final AccountActions _account = widget.account ?? const FirebaseAccount();
  late final TextEditingController _username = TextEditingController(text: widget.currentUsername);
  late final String _oldEmail = _account.email ?? '';
  late final TextEditingController _email = TextEditingController(text: _oldEmail);
  final TextEditingController _newPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();

  /// The chosen avatar (0–5); an old DiceBear picture starts on its slot.
  late int _avatar = avatarIndexOf(widget.currentPhotoUrl) ?? 0;
  bool _saving = false;
  String? _usernameError, _emailError, _newPasswordError, _confirmError, _currentError;

  @override
  void dispose() {
    for (final c in [_username, _email, _newPassword, _confirmPassword, _currentPassword]) {
      c.dispose();
    }
    super.dispose();
  }

  void _clearErrors() {
    _usernameError = _emailError = _newPasswordError = _confirmError = _currentError = null;
  }

  void _showProblem(Object e, AppLocalizations t) {
    final problem = AccountException.from(e).problem;
    setState(() {
      switch (problem) {
        case AccountProblem.wrongPassword:
          _currentError = t.editWrongPassword;
        case AccountProblem.emailInUse:
          _emailError = t.editEmailInUse;
        case AccountProblem.invalidEmail:
          _emailError = t.commonEmailLooksWrong;
        case AccountProblem.weakPassword:
          _newPasswordError = t.commonAtLeast6;
        default:
          break;
      }
    });
    final message = switch (problem) {
      AccountProblem.network => t.editNoInternet,
      AccountProblem.tooManyTries => t.editTooManyTries,
      AccountProblem.other => t.editCouldntSave,
      _ => null,
    };
    if (message != null) showV6Snackbar(context, message, icon: Icons.error_rounded);
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final name = _username.text.trim();
    final email = _email.text.trim();
    final newPassword = _newPassword.text;
    final emailChanged = email != _oldEmail;
    final passwordChanged = newPassword.isNotEmpty;

    setState(() {
      _clearErrors();
      if (name.isEmpty) {
        _usernameError = t.editUsernameEmpty;
      } else if (name.length < 3) {
        _usernameError = t.editUsernameShort;
      }
      if (emailChanged && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
        _emailError = email.isEmpty ? t.commonEnterYourEmail : t.commonEmailLooksWrong;
      }
      if (passwordChanged && newPassword.length < 6) _newPasswordError = t.commonAtLeast6;
      if ((passwordChanged || _confirmPassword.text.isNotEmpty) && _confirmPassword.text != newPassword) {
        _confirmError = t.commonPasswordsDontMatch;
      }
      if ((emailChanged || passwordChanged) && _currentPassword.text.isEmpty) _currentError = t.editNeedPassword;
    });
    if ([_usernameError, _emailError, _newPasswordError, _confirmError, _currentError].any((e) => e != null)) return;

    setState(() => _saving = true);
    try {
      // The current password first, so nothing changes when it is wrong.
      if (emailChanged || passwordChanged) await _account.confirmPassword(_currentPassword.text);
      await _account.saveProfile(name, avatarValue(_avatar));
      if (passwordChanged) await _account.changePassword(newPassword);
      if (emailChanged) {
        await _account.changeEmail(email);
        if (mounted) setState(() => _saving = false);
        if (mounted) await _checkNewEmail(email);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _showProblem(e, t);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Figma 629:6726: OK, or Resend link (sends the same link again).
  Future<void> _checkNewEmail(String email) async {
    final t = AppLocalizations.of(context);
    while (true) {
      if (!mounted) return;
      final picked = await showV6ChoiceDialog(
        context,
        mascot: 'firefly_find',
        mascotCircle: V6Colors.citrus,
        title: t.editCheckEmailTitle,
        message: t.editCheckEmailBody(email),
        primaryLabel: t.commonOk,
        textActions: [t.editResendLink],
        barrierDismissible: false,
      );
      if (picked != t.editResendLink || !mounted) return;
      try {
        await _account.changeEmail(email);
        if (mounted) showV6Snackbar(context, t.editLinkSent);
      } catch (e) {
        if (mounted) _showProblem(e, t);
        return;
      }
    }
  }

  /// Figma 618:5935. The current password must be filled in first; a wrong
  /// one shows the error and nothing is deleted.
  Future<void> _deleteAccount() async {
    final t = AppLocalizations.of(context);
    if (_currentPassword.text.isEmpty) {
      setState(() {
        _clearErrors();
        _currentError = t.editNeedPasswordDelete;
      });
      return;
    }
    final picked = await showV6ChoiceDialog(
      context,
      mascot: 'firefly_crying',
      mascotCircle: V6Colors.coralTonal,
      title: t.editDeleteTitle,
      message: t.editDeleteBody,
      primaryLabel: t.editDeleteKeep,
      textActions: [t.editDeleteAccount],
      dangerActions: {t.editDeleteAccount},
    );
    if (picked != t.editDeleteAccount || !mounted) return;
    setState(() {
      _clearErrors();
      _saving = true;
    });
    try {
      await _account.confirmPassword(_currentPassword.text);
      await _account.deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAccountDeleted?.call();
    } catch (e) {
      if (mounted) _showProblem(e, t);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _forgotPassword() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialEmail: _oldEmail)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const gap = SizedBox(height: 16);
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: t.editTitle, onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(t.editChooseAvatar, style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < kAvatarCount; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _AvatarTile(
                            index: i,
                            label: t.editAvatar(i + 1),
                            selected: i == _avatar,
                            onTap: () => setState(() => _avatar = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(t.meAccount, style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6TextField(
                    label: t.authUsername,
                    controller: _username,
                    prefixIcon: Icons.person_rounded,
                    maxLength: 30,
                    errorText: _usernameError,
                    textInputAction: TextInputAction.next,
                  ),
                  gap,
                  V6TextField(
                    label: t.commonEmail,
                    controller: _email,
                    prefixIcon: Icons.mail_rounded,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    textInputAction: TextInputAction.next,
                  ),
                  gap,
                  V6TextField(
                    label: t.editNewPassword,
                    hint: t.editNewPassword,
                    controller: _newPassword,
                    prefixIcon: Icons.lock_rounded,
                    obscure: true,
                    errorText: _newPasswordError,
                    textInputAction: TextInputAction.next,
                  ),
                  gap,
                  V6TextField(
                    label: t.editConfirmNewPassword,
                    hint: t.editConfirmNewPassword,
                    controller: _confirmPassword,
                    prefixIcon: Icons.lock_rounded,
                    obscure: true,
                    errorText: _confirmError,
                    textInputAction: TextInputAction.next,
                  ),
                  gap,
                  V6TextField(
                    label: t.editCurrentPassword,
                    hint: t.editCurrentPasswordHint,
                    controller: _currentPassword,
                    prefixIcon: Icons.shield_rounded,
                    obscure: true,
                    errorText: _currentError,
                    helperText: t.editOnlyNeeded,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: V6Button(
                      label: t.editForgotPassword,
                      style: V6ButtonStyle.text,
                      onPressed: _saving ? null : _forgotPassword,
                    ),
                  ),
                  const SizedBox(height: 12),
                  V6Button(label: t.editSaveChanges, expand: true, loading: _saving, onPressed: _save),
                  const SizedBox(height: 12),
                  Center(
                    child: V6Button(
                      label: t.editDeleteAccount,
                      style: V6ButtonStyle.dangerText,
                      onPressed: _saving ? null : _deleteAccount,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One avatar in the row: white rounded tile; selected = 2 px violet border
/// and a check badge.
class _AvatarTile extends StatelessWidget {
  const _AvatarTile({required this.index, required this.label, required this.selected, required this.onTap});

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: V6Colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? V6Colors.primary : V6Colors.borderDivider,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(avatarAsset(index), fit: BoxFit.cover),
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: V6Colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: V6Colors.primary, width: 1.5),
                    ),
                    child: const Icon(Icons.check_rounded, size: 14, color: V6Colors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
