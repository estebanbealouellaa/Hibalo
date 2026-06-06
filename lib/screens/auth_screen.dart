import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as app_auth;

// ── Hibalo Theme Colors ─────────────────────────────────────────────
const Color _purple900 = Color(0xFF6D28D9);
const Color _purple700 = Color(0xFF7C3AED);
const Color _purple600 = Color(0xFF9333EA);
const Color _purpleLight = Color(0xFFF3E8FF);
const Color _white = Colors.white;

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();

    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();

    super.dispose();
  }

  // ── SWITCH LOGIN/SIGNUP ──────────────────────────────────────────
  void _switchMode() {
    _formKey.currentState?.reset();
    _animCtrl.reset();

    setState(() {
      _isLogin = !_isLogin;
    });

    _animCtrl.forward();
  }

  // ── SUBMIT — now uses AuthProvider so admin role is detected ─────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    // Use AuthProvider instead of FirebaseAuth directly
    final authProvider = context.read<app_auth.AuthProvider>();

    bool success = false;
    String? errorMsg;

    if (_isLogin) {
      // ── LOGIN ─────────────────────────────────
      success = await authProvider.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      errorMsg = authProvider.errorMessage;
    } else {
      // ── REGISTER ──────────────────────────────
      success = await authProvider.signUp(
        name: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
      errorMsg = authProvider.errorMessage;
    }

    if (!mounted) return;

    if (success) {
      widget.onAuthSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg ?? 'Authentication failed')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_purple900, _purple700, Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),

              child: FadeTransition(
                opacity: _fadeAnim,

                child: SlideTransition(
                  position: _slideAnim,

                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color: _white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _white.withOpacity(0.25), width: 2),
          ),
          child: const Center(
            child: Text('🐝', style: TextStyle(fontSize: 46)),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          _isLogin ? 'Welcome Back!' : 'Join Hibalo!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _white,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          _isLogin
              ? 'Sign in to continue translating'
              : 'Create your account to get started',
          style: TextStyle(color: _white.withOpacity(0.75), fontSize: 14),
        ),
      ],
    );
  }

  // ── CARD ─────────────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),

      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Form(
        key: _formKey,

        child: Column(
          children: [
            _buildToggle(),

            const SizedBox(height: 24),

            // USERNAME (signup only)
            if (!_isLogin) ...[
              _buildField(
                controller: _usernameCtrl,
                label: 'Username',
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter username';
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],

            // EMAIL
            _buildField(
              controller: _emailCtrl,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter email';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),

            const SizedBox(height: 14),

            // PASSWORD
            _buildField(
              controller: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscurePass,
              onToggleObscure: () =>
                  setState(() => _obscurePass = !_obscurePass),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter password';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),

            // CONFIRM PASSWORD (signup only)
            if (!_isLogin) ...[
              const SizedBox(height: 14),
              _buildField(
                controller: _confirmCtrl,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v != _passwordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],

            const SizedBox(height: 28),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple700,
                  foregroundColor: _white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: _white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // SWITCH MODE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin
                      ? "Don't have an account? "
                      : "Already have an account? ",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                GestureDetector(
                  onTap: _switchMode,
                  child: Text(
                    _isLogin ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(
                      color: _purple700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── TOGGLE ───────────────────────────────────────────────────────
  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _purpleLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _toggleBtn('Sign In', _isLogin, () {
            if (!_isLogin) _switchMode();
          }),
          _toggleBtn('Sign Up', !_isLogin, () {
            if (_isLogin) _switchMode();
          }),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? _purple700 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? _white : _purple700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── TEXT FIELD ───────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _purple600),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFFAF5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple700, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
