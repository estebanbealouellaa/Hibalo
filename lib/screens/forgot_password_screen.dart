import '../l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/v6/v6.dart';

/// Sends the reset email. The real one is FirebaseAuth; tests pass a fake.
typedef SendPasswordReset = Future<void> Function(String email);

Future<void> _firebaseSendReset(String email) =>
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);

/// Forgot password (Figma 635:6866) → Check your email (635:6923).
/// Opened from Sign In. "Send reset link" calls FirebaseAuth
/// sendPasswordResetEmail; "Back to sign in" returns; "Resend link" sends
/// it again.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = '', this.sendReset});

  final String initialEmail;
  final SendPasswordReset? sendReset;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _emailCtrl = TextEditingController(text: widget.initialEmail);

  bool _loading = false;
  bool _sent = false;
  V6Banner? _banner;

  SendPasswordReset get _send => widget.sendReset ?? _firebaseSendReset;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<bool> _sendLink() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _banner = null;
    });
    try {
      await _send(_emailCtrl.text.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Reset failed: ${e.code} ${e.message}');
      if (mounted) {
        setState(() => _banner = e.code == 'network-request-failed'
            ? V6Banner(type: V6BannerType.warning, message: t.forgotNoInternet)
            : V6Banner(type: V6BannerType.error, message: e.message ?? t.commonSomethingWrong));
      }
      return false;
    } catch (e) {
      debugPrint('Reset failed: $e');
      if (mounted) setState(() => _banner = V6Banner(type: V6BannerType.error, message: 'Error: $e'));
      return false;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (await _sendLink() && mounted) setState(() => _sent = true);
  }

  Future<void> _resend() async {
    final t = AppLocalizations.of(context);
    if (await _sendLink() && mounted) showV6Snackbar(context, t.forgotLinkSentAgain);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [V6Wordmark(), V6LogoMark()],
                        ),
                        const SizedBox(height: 24),
                        Text(_sent ? t.forgotCheckEmail : t.forgotTitle, style: V6Text.headlineXl),
                        const SizedBox(height: 8),
                        Text(
                          _sent
                              ? t.forgotSentTo(_emailCtrl.text.trim())
                              : t.forgotBody,
                          style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
                        ),
                        const SizedBox(height: 24),
                        if (_banner != null) ...[_banner!, const SizedBox(height: 24)],
                        if (_sent)
                          const Center(
                            child: V6MascotCircle(
                              mascot: 'firefly_find',
                              circleColor: V6Colors.glow,
                              size: 276,
                              circleSize: 150,
                            ),
                          )
                        else ...[
                          const SizedBox(height: 44),
                          V6TextField(
                            controller: _emailCtrl,
                            label: t.commonEmail,
                            hint: t.commonEnterEmail,
                            fieldLabel: true,
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            onSubmitted: (_) => _submit(),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return t.commonEnterYourEmail;
                              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                                return t.commonEmailLooksWrong;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          V6Button(
                            label: _loading ? t.forgotSending : t.forgotSendLink,
                            loading: _loading,
                            expand: true,
                            onPressed: _submit,
                          ),
                        ],
                        const Spacer(),
                        const SizedBox(height: 16),
                        if (_sent)
                          V6Button(
                            label: t.forgotBackToSignIn,
                            expand: true,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _sent ? t.forgotDidntGetIt : t.forgotRemembered,
                              style: V6Text.bodyMedium.copyWith(color: V6Colors.textNeutralStrong),
                            ),
                            const SizedBox(width: 4),
                            _sent
                                ? V6TextLink(label: t.forgotResend, onTap: _loading ? null : _resend)
                                : V6TextLink(
                                    label: t.forgotBackToSignIn,
                                    onTap: () => Navigator.of(context).maybePop(),
                                  ),
                          ],
                        ),
                      ],
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
}
