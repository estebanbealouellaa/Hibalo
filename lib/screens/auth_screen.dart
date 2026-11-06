import '../l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../widgets/v6/v6.dart';
import 'forgot_password_screen.dart';

/// Sign In / Sign Up (Figma 468:1887, 468:1908): only the layout is V6; submitting and validation work as before.
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  /// Opens on Sign Up (Welcome's Get started) instead of Sign In.
  final bool startWithSignUp;

  const AuthScreen({super.key, required this.onAuthSuccess, this.startWithSignUp = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// The banner shown above the form after a failed sign in / sign up.
class AuthBanner {
  const AuthBanner(this.type, this.message, {this.emailTaken = false});

  final V6BannerType type;
  final String message;

  /// "This email is already in use." also marks the email field.
  final bool emailTaken;

  /// Maps Firebase's error [code] to the Figma banner (no connection, wrong email or password, email in use, else Firebase's message).
  static AuthBanner fromError({
    required AppLocalizations t,
    required String? code,
    required String? message,
    required bool isLogin,
  }) {
    if (code == 'network-request-failed') {
      return AuthBanner(
        V6BannerType.warning,
        isLogin ? t.authNoInternetSignIn : t.authNoInternetSignUp,
      );
    }
    if (isLogin &&
        const {'invalid-credential', 'wrong-password', 'user-not-found', 'invalid-email', 'INVALID_LOGIN_CREDENTIALS'}
            .contains(code)) {
      return AuthBanner(V6BannerType.error, t.authWrongCredentials);
    }
    if (!isLogin && code == 'email-already-in-use') {
      return AuthBanner(V6BannerType.error, t.authEmailInUse, emailTaken: true);
    }
    return AuthBanner(V6BannerType.error, message ?? t.commonSomethingWrong);
  }
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin = !widget.startWithSignUp;
  bool _loading = false;
  AuthBanner? _banner;

  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordCtrl.addListener(() {
      if (!_isLogin) setState(() {}); // refresh the strength meter
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _setMode(bool login) {
    if (login == _isLogin) return;
    HapticFeedback.selectionClick();
    _formKey.currentState?.reset();
    setState(() {
      _isLogin = login;
      _banner = null;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _loading = true;
      _banner = null;
    });
    final auth = context.read<app_auth.AuthProvider>();

    try {
      // Passwords are sent exactly as typed; only name and email are trimmed.
      final success = _isLogin
          ? await auth.signIn(
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            )
          : await auth.signUp(
              name: _usernameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text,
            );

      if (!mounted) return;
      if (success) {
        HapticFeedback.mediumImpact();
        widget.onAuthSuccess();
      } else {
        debugPrint('Auth failed: ${auth.errorCode} ${auth.errorMessage}');
        _showError(AuthBanner.fromError(t: AppLocalizations.of(context), code: auth.errorCode, message: auth.errorMessage, isLogin: _isLogin));
      }
    } catch (e, st) {
      debugPrint('Auth exception: $e\n$st');
      if (mounted) _showError(AuthBanner(V6BannerType.error, 'Error: $e'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(AuthBanner banner) {
    HapticFeedback.heavyImpact();
    setState(() => _banner = banner);
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForgotPasswordScreen(initialEmail: _emailCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: V6Colors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _header(),
                          // Figma: Sign Up's form starts 52 below the header
                          // (24 when a banner sits in between).
                          SizedBox(height: _isLogin || _banner != null ? 24 : 52),
                          if (_banner != null) ...[
                            V6Banner(type: _banner!.type, message: _banner!.message),
                            const SizedBox(height: 24),
                          ],
                          _form(),
                          const Spacer(),
                          const SizedBox(height: 16),
                          _actions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [V6Wordmark(), V6LogoMark()],
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? t.authWelcomeBack : t.authJoin,
          style: V6Text.headlineXl,
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin
              ? t.authWelcomeBackSub
              : t.authJoinSub,
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
        ),
      ],
    );
  }

  Widget _form() {
    final t = AppLocalizations.of(context);
    final gap = SizedBox(height: _isLogin ? 16 : 8);
    final enabled = !_loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isLogin) ...[
          V6TextField(
            key: const ValueKey('username'),
            controller: _usernameCtrl,
            label: t.authUsername,
            hint: t.authEnterUsername,
            fieldLabel: true,
            enabled: enabled,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return t.authEnterAUsername;
              if (value.length < 2) return t.authAtLeast2;
              return null;
            },
          ),
          gap,
        ],
        V6TextField(
          key: const ValueKey('email'),
          controller: _emailCtrl,
          label: t.commonEmail,
          hint: t.commonEnterEmail,
          fieldLabel: true,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: (_banner?.emailTaken ?? false) ? '' : null,
          onChanged: (_) {
            if (_banner?.emailTaken ?? false) setState(() => _banner = null);
          },
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return t.commonEnterYourEmail;
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
              return t.commonEmailLooksWrong;
            }
            return null;
          },
        ),
        gap,
        V6TextField(
          key: const ValueKey('password'),
          controller: _passwordCtrl,
          label: t.commonPassword,
          hint: t.commonPassword,
          fieldLabel: true,
          obscure: true,
          enabled: enabled,
          textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
          autofillHints: _isLogin ? const [AutofillHints.password] : const [AutofillHints.newPassword],
          onSubmitted: _isLogin ? (_) => _submit() : null,
          validator: (v) {
            if (v == null || v.isEmpty) return t.authEnterPassword;
            if (v.length < 6) return t.commonAtLeast6;
            return null;
          },
        ),
        if (_isLogin) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: V6Button(
              label: t.authForgotPassword,
              style: V6ButtonStyle.text,
              onPressed: _loading ? null : _openForgotPassword,
            ),
          ),
        ] else ...[
          gap,
          StrengthMeter(password: _passwordCtrl.text),
          gap,
          V6TextField(
            key: const ValueKey('confirm'),
            controller: _confirmCtrl,
            label: t.authConfirmPassword,
            hint: t.authReenterPassword,
            fieldLabel: true,
            obscure: true,
            enabled: enabled,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: (v) {
              if (v != _passwordCtrl.text) {
                return t.commonPasswordsDontMatch;
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _actions() {
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        V6Button(
          label: _loading
              ? (_isLogin ? t.authSigningIn : t.authCreatingAccount)
              : (_isLogin ? t.authSignIn : t.authCreateAccount),
          loading: _loading,
          expand: true,
          onPressed: _submit,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              _isLogin ? t.authNewToHibalo : t.authHaveAccount,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textNeutralStrong),
            ),
            const SizedBox(width: 4),
            V6TextLink(
              label: _isLogin ? t.authCreateAnAccount : t.authSignIn,
              onTap: _loading ? null : () => _setMode(!_isLogin),
            ),
          ],
        ),
      ],
    );
  }
}

class StrengthMeter extends StatelessWidget {
  final String password;
  const StrengthMeter({super.key, required this.password});

  int get _score {
    var s = 0;
    if (password.length >= 6) s++;
    if (password.length >= 10) s++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      s++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s++;
    return math.min(s, 4);
  }

  @override
  Widget build(BuildContext context) {
    final s = password.isEmpty ? 0 : _score;
    const colors = [V6Colors.error, V6Colors.warning, V6Colors.success, V6Colors.success];
    final t = AppLocalizations.of(context);
    final labels = [t.authStrengthTooWeak, t.authStrengthFair, t.authStrengthGood, t.authStrengthStrong];
    final color = s == 0 ? V6Colors.borderDivider : colors[s - 1];

    return SizedBox(
      height: 16,
      child: Row(
        children: [
          for (int i = 0; i < 4; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: i < s ? color : V6Colors.borderDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 8),
          ],
          if (password.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              labels[math.max(s - 1, 0)],
              style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
