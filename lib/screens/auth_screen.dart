import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  /// Entrance animation for the whole screen.
  late final AnimationController _intro;

  /// Slow ambient motion for the background orbs and the firefly.
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _passwordCtrl.addListener(() {
      if (!_isLogin) setState(() {}); // refresh the strength meter
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Switch between sign in and sign up ─────────────────────────────────
  void _setMode(bool login) {
    if (login == _isLogin) return;
    HapticFeedback.selectionClick();
    _formKey.currentState?.reset();
    setState(() => _isLogin = login);
  }

  // ── Submit ─────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _loading = true);
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
        debugPrint('Auth failed: ${auth.errorMessage}');
        _showError(auth.errorMessage ?? 'Something went wrong. Try again.');
      }
    } catch (e, st) {
      debugPrint('Auth exception: $e\n$st');
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A1F3D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFFF8FA3)),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  /// Fade-and-rise for one element on its own slice of the intro.
  Widget _enter(double begin, Widget child) {
    final a = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        begin,
        math.min(begin + 0.5, 1),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * 22),
          child: c,
        ),
      ),
      child: child,
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: purpleDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [purpleDark, purple, purpleMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _ambient,
                  builder: (_, __) => CustomPaint(
                    painter: _OrbPainter(reduce ? 0 : _ambient.value),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        _enter(0, _header(reduce)),
                        const SizedBox(height: 28),
                        _enter(0.2, _card()),
                        const SizedBox(height: 22),
                        _enter(0.4, _footer()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: firefly logo, title, Hiligaynon greeting ───────────────────
  Widget _header(bool reduce) {
    return Column(
      children: [
        SizedBox(
          width: 104,
          height: 104,
          child: AnimatedBuilder(
            animation: _ambient,
            builder: (_, __) => CustomPaint(
              painter: _FireflyPainter(t: reduce ? 0.15 : _ambient.value),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(a),
              child: c,
            ),
          ),
          child: Column(
            key: ValueKey(_isLogin),
            children: [
              Text(
                _isLogin ? 'Welcome back' : 'Join Hibalo',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin
                    ? 'Sign in to keep translating and learning.'
                    : 'Make an account to save your lessons, XP and streak.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              // One Hiligaynon phrase on the way in.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Kamusta ka?' : 'Maayong pag-abot!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLogin ? 'How are you?' : 'Welcome!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Card with the form ────────────────────────────────────────────────
  Widget _card() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _toggle(),
            const SizedBox(height: 22),

            // Username slides in for sign up.
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isLogin
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _field(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.person_outline_rounded,
                        action: TextInputAction.next,
                        autofill: const [AutofillHints.username],
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Enter a username';
                          if (t.length < 2) return 'At least 2 characters';
                          return null;
                        },
                      ),
                    ),
            ),

            _field(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              action: TextInputAction.next,
              autofill: const [AutofillHints.email],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter your email';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                  return 'That email doesn\'t look right';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            _field(
              controller: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePass,
              onToggleObscure: () =>
                  setState(() => _obscurePass = !_obscurePass),
              action: _isLogin ? TextInputAction.done : TextInputAction.next,
              autofill: _isLogin
                  ? const [AutofillHints.password]
                  : const [AutofillHints.newPassword],
              onSubmitted: _isLogin ? (_) => _submit() : null,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),

            // Strength meter + confirm field slide in for sign up.
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _isLogin
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      children: [
                        const SizedBox(height: 10),
                        _StrengthMeter(password: _passwordCtrl.text),
                        const SizedBox(height: 14),
                        _field(
                          controller: _confirmCtrl,
                          label: 'Confirm password',
                          icon: Icons.lock_reset_rounded,
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          action: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: _PushButton(
                onTap: _loading ? null : _submit,
                loading: _loading,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _isLogin ? 'Sign in' : 'Create account',
                    key: ValueKey(_isLogin),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Segmented toggle with a sliding pill ──────────────────────────────
  Widget _toggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: purplePale,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (_, c) {
          final half = c.maxWidth / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutBack,
                left: _isLogin ? 0 : half,
                top: 0,
                bottom: 0,
                width: half,
                child: Container(
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  _toggleLabel('Sign in', _isLogin, () => _setMode(true)),
                  _toggleLabel('Sign up', !_isLogin, () => _setMode(false)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleLabel(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: TextStyle(
              color: active ? Colors.white : purple,
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  // ── Text field ─────────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? action,
    Iterable<String>? autofill,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      autofillHints: autofill,
      obscureText: obscure,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      enabled: !_loading,
      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: const TextStyle(
          color: purple,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(icon, color: purple, size: 22),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                tooltip: obscure ? 'Show password' : 'Hide password',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    key: ValueKey(obscure),
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.grey.shade200),
        disabledBorder: border(Colors.grey.shade200),
        focusedBorder: border(purple, 1.8),
        errorBorder: border(const Color(0xFFE5486B)),
        focusedErrorBorder: border(const Color(0xFFE5486B), 1.8),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────
  Widget _footer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? 'New to Hibalo? ' : 'Already have an account? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: () => _setMode(!_isLogin),
              child: Text(
                _isLogin ? 'Create an account' : 'Sign in',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white54,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Hiligaynon · Filipino',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 11.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PASSWORD STRENGTH
// ═════════════════════════════════════════════════════════════════════════════
class _StrengthMeter extends StatelessWidget {
  final String password;
  const _StrengthMeter({required this.password});

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
    const colors = [
      Color(0xFFE5486B),
      Color(0xFFF08C3A),
      Color(0xFFF2C14E),
      Color(0xFF3BB78F),
    ];
    const labels = ['Too weak', 'Fair', 'Good', 'Strong'];
    final color = s == 0 ? Colors.grey.shade300 : colors[s - 1];

    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 5,
              decoration: BoxDecoration(
                color: i < s ? color : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 5),
        ],
        const SizedBox(width: 10),
        SizedBox(
          width: 62,
          child: Text(
            password.isEmpty ? '' : labels[math.max(s - 1, 0)],
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PUSH BUTTON — presses down like a real key, shows a spinner while busy
// ═════════════════════════════════════════════════════════════════════════════
class _PushButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool loading;
  const _PushButton({
    required this.child,
    required this.onTap,
    this.loading = false,
  });

  @override
  State<_PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<_PushButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    const depth = 5.0;
    final enabled = widget.onTap != null;
    final base = enabled || widget.loading ? purple : Colors.grey.shade300;
    final edge = HSLColor.fromColor(base)
        .withLightness(
          (HSLColor.fromColor(base).lightness - 0.14).clamp(0.0, 1.0),
        )
        .toColor();

    return GestureDetector(
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled
          ? (_) {
              _set(false);
              HapticFeedback.lightImpact();
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => _set(false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        height: 56,
        margin: EdgeInsets.only(
          top: _down ? depth : 0,
          bottom: _down ? 0 : depth,
        ),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: edge, offset: Offset(0, _down ? 0 : depth)),
          ],
        ),
        alignment: Alignment.center,
        child: widget.loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.6,
                ),
              )
            : DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
                child: widget.child,
              ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// THE HIBALO LOGO — a firefly (alitaptap)
//
// A small light that finds its way in the dark, for an app whose name means
// "to know". The wings flutter, the lantern glows, and a trail of light
// drifts behind it. [t] runs 0..1 and loops.
// ═════════════════════════════════════════════════════════════════════════════
class _FireflyPainter extends CustomPainter {
  /// 0..1, loops with the ambient controller.
  final double t;

  /// Wing beats per loop of [t]. A whole number keeps the loop seamless.
  final int flaps;

  _FireflyPainter({required this.t, this.flaps = 30});

  static const Color _gold = Color(0xFFFFD45C);
  static const Color _goldDeep = Color(0xFFFFB627);
  static const Color _ink = Color(0xFF3B2470);

  double _wave(double cycles, [double phase = 0]) =>
      math.sin((t * cycles + phase) * 2 * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 120;
    canvas.save();
    canvas.translate((size.width - 120 * s) / 2, (size.height - 120 * s) / 2);
    canvas.scale(s);

    final pulse = (_wave(4) + 1) / 2; // lantern glow, 0..1
    final bob = _wave(4, 0.25) * 2.2; // gentle hover

    // Halo behind everything.
    canvas.drawCircle(
      const Offset(60, 60),
      54 + pulse * 3,
      Paint()..color = Colors.white.withOpacity(0.06 + pulse * 0.04),
    );
    canvas.drawCircle(
      const Offset(60, 60),
      44,
      Paint()..color = Colors.white.withOpacity(0.10),
    );

    canvas.translate(0, bob);
    _trail(canvas);

    // Tilt so it reads as flying up and to the right.
    canvas.save();
    canvas.translate(62, 58);
    canvas.rotate(0.42);
    canvas.translate(-60, -60);

    _glow(canvas, pulse);
    _wings(canvas);
    _body(canvas, pulse);

    canvas.restore();
    canvas.restore();
  }

  // Trail of light dots drifting behind the firefly.
  void _trail(Canvas canvas) {
    for (int i = 0; i < 6; i++) {
      final p = ((t * 4 + i / 6) % 1);
      final x = 44 - p * 30 - i * 1.5;
      final y = 84 + p * 22 + math.sin(p * math.pi) * -6;
      final r = 3.2 * (1 - p) + 0.6;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = _gold.withOpacity((1 - p) * 0.75),
      );
    }
  }

  // Soft glow around the lantern.
  void _glow(Canvas canvas, double pulse) {
    const c = Offset(60, 80);
    final r = 30 + pulse * 6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _gold.withOpacity(0.55 + pulse * 0.25),
            _gold.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  // Two pairs of fluttering wings.
  void _wings(Canvas canvas) {
    final flap = _wave(flaps.toDouble()) * 0.32;

    for (final side in [-1.0, 1.0]) {
      for (final layer in [0, 1]) {
        canvas.save();
        canvas.translate(60 + side * 4, 52);
        canvas.rotate(side * (0.75 + (layer == 0 ? 0.35 : 0) + flap));
        final w = layer == 0 ? 15.0 : 18.0;
        final h = layer == 0 ? 30.0 : 38.0;
        final rect = Rect.fromCenter(
          center: Offset(0, -h / 2 + 2),
          width: w,
          height: h,
        );
        canvas.drawOval(
          rect,
          Paint()..color = Colors.white.withOpacity(layer == 0 ? 0.35 : 0.72),
        );
        canvas.drawOval(
          rect,
          Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        canvas.drawLine(
          Offset.zero,
          Offset(0, -h + 8),
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..strokeWidth = 1,
        );
        canvas.restore();
      }
    }
  }

  // Head, thorax and the glowing lantern.
  void _body(Canvas canvas, double pulse) {
    final lantern = Rect.fromCenter(
      center: const Offset(60, 78),
      width: 22,
      height: 30,
    );
    canvas.drawOval(
      lantern,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(_goldDeep, _gold, 0.3)!,
            Color.lerp(_gold, Colors.white, pulse * 0.45)!,
          ],
        ).createShader(lantern),
    );

    final seg = Paint()
      ..color = _goldDeep.withOpacity(0.7)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(60, 70), width: 18, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(60, 77), width: 20, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );

    final body = Paint()..color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 55), width: 20, height: 18),
      body,
    );
    canvas.drawCircle(const Offset(60, 41), 8.5, body);

    final eye = Paint()..color = _ink;
    canvas.drawCircle(const Offset(56.5, 40), 2.1, eye);
    canvas.drawCircle(const Offset(63.5, 40), 2.1, eye);

    // Antennae with glowing tips.
    final ant = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final sway = _wave(4, 0.1) * 1.5;
    canvas.drawPath(
      Path()
        ..moveTo(57, 34)
        ..quadraticBezierTo(52, 24, 45 + sway, 19),
      ant,
    );
    canvas.drawPath(
      Path()
        ..moveTo(63, 34)
        ..quadraticBezierTo(68, 24, 75 + sway, 19),
      ant,
    );
    final tip = Paint()..color = _gold;
    canvas.drawCircle(Offset(45 + sway, 19), 2.6, tip);
    canvas.drawCircle(Offset(75 + sway, 19), 2.6, tip);
  }

  @override
  bool shouldRepaint(_FireflyPainter old) => old.t != t;
}

// ═════════════════════════════════════════════════════════════════════════════
// BACKGROUND ORBS
// ═════════════════════════════════════════════════════════════════════════════
class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  static const List<List<double>> _orbs = [
    [0.10, 0.12, 0.38, 1.0, 0.0],
    [0.92, 0.30, 0.28, 0.7, 0.3],
    [0.80, 0.90, 0.44, 0.5, 0.6],
    [0.12, 0.74, 0.24, 0.9, 0.8],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _orbs.length; i++) {
      final o = _orbs[i];
      final drift = math.sin((t * o[3] + o[4]) * 2 * math.pi);
      final center = Offset(
        o[0] * size.width + drift * 18,
        o[1] * size.height - drift * 22,
      );
      final r = o[2] * size.width;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(i.isEven ? 0.07 : 0.05),
              Colors.white.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
