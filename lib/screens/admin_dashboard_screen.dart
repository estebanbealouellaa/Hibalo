import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'admin_users_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME TOKENS
// ─────────────────────────────────────────────────────────────────────────────

class _DashTheme {
  final bool isDark;
  const _DashTheme(this.isDark);

  // backgrounds
  Color get bg => isDark ? const Color(0xFF0D0F18) : const Color(0xFFF4F6FB);
  Color get surface => isDark ? const Color(0xFF161927) : Colors.white;
  Color get surfaceAlt =>
      isDark ? const Color(0xFF1E2235) : const Color(0xFFEEF1F8);

  // text
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0D0F18);
  Color get textSecondary =>
      isDark ? const Color(0xFF8A91AA) : const Color(0xFF6B7280);
  Color get textMuted =>
      isDark ? const Color(0xFF444B63) : const Color(0xFFB0B7C8);

  // border / divider
  Color get border =>
      isDark ? const Color(0xFF262B40) : const Color(0xFFE4E8F0);

  // accent
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentGlow = Color(0x336C63FF);
  static const Color amber = Color(0xFFFFA726);
  static const Color rose = Color(0xFFFF6B8A);
  static const Color teal = Color(0xFF00D4B4);

  // card gradient overlays
  Color get cardOverlay =>
      isDark ? const Color(0x0DFFFFFF) : const Color(0x06000000);
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const AdminDashboardScreen({super.key, required this.onLogout});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── stats ──
  int _totalUsers = 0, _dailyActive = 0, _weeklyActive = 0, _totalAdmins = 0;
  bool _loading = true;

  // ── theme ──
  late bool _isDark;
  // ── animations ──
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Auto theme based on time
    final hour = DateTime.now().hour;
    _isDark = hour >= 12; // AM = light, PM = dark

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _loadStats();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── LOAD STATS ───────────────────────────────────
  Future<void> _loadStats() async {
    setState(() => _loading = true);
    _fadeCtrl.reset();

    try {
      final usersSnap = await _db.collection('users').get();
      final adminsSnap = await _db
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final dailySnap = await _db
          .collection('users')
          .where('lastActive', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();
      final weeklySnap = await _db
          .collection('users')
          .where('lastActive', isGreaterThan: Timestamp.fromDate(lastWeek))
          .get();

      _totalUsers = usersSnap.size;
      _totalAdmins = adminsSnap.size;
      _dailyActive = dailySnap.size;
      _weeklyActive = weeklySnap.size;
    } catch (e) {
      debugPrint('Stats error: $e');
    }

    setState(() => _loading = false);
    _fadeCtrl.forward();
  }

  // ── LOGOUT ───────────────────────────────────────
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
  }

  // ── TOGGLE THEME ─────────────────────────────────
  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  // ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = _DashTheme(_isDark);
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: t.bg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(t, greeting),
              Expanded(
                child: _loading
                    ? _buildLoader(t)
                    : FadeTransition(
                        opacity: _fadeAnim,
                        child: RefreshIndicator(
                          color: _DashTheme.accent,
                          backgroundColor: t.surface,
                          onRefresh: _loadStats,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsGrid(t),
                                const SizedBox(height: 28),
                                _buildSectionLabel('Management', t),
                                const SizedBox(height: 12),
                                _buildManagementTile(
                                  t: t,
                                  icon: Icons.manage_accounts_rounded,
                                  label: 'Manage Users',
                                  subtitle:
                                      'View, edit, promote or remove users',
                                  color: _DashTheme.accent,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdminUsersScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildManagementTile(
                                  t: t,
                                  icon: Icons.bar_chart_rounded,
                                  label: 'Usage Analytics',
                                  subtitle:
                                      'Daily & weekly active user breakdown',
                                  color: _DashTheme.teal,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AdminUsageScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _buildSectionLabel('Recent Signups', t),
                                const SizedBox(height: 12),
                                _buildRecentUsers(t),
                              ],
                            ),
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

  // ─────────────────────────────────────────────────
  // TOP BAR  — FIX: compact layout, no text wrap
  // ─────────────────────────────────────────────────
  Widget _buildTopBar(_DashTheme t, String greeting) {
    final timeStr = DateFormat('h:mm a').format(DateTime.now());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _DashTheme.accentGlow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          // TITLE — FIX: wrap in Expanded so it never overflows
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: t.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 15, // reduced from 17 to prevent wrapping
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // TIME CHIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: t.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                color: t.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // THEME TOGGLE
          _iconBtn(
            icon: _isDark ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
            color: _isDark ? _DashTheme.amber : const Color(0xFF6C63FF),
            bg: t.surfaceAlt,
            border: t.border,
            onTap: _toggleTheme,
            tooltip: _isDark ? 'Switch to Light' : 'Switch to Dark',
          ),

          const SizedBox(width: 4),

          // REFRESH
          _iconBtn(
            icon: Icons.refresh_rounded,
            color: t.textSecondary,
            bg: t.surfaceAlt,
            border: t.border,
            onTap: _loadStats,
            tooltip: 'Refresh',
          ),

          const SizedBox(width: 4),

          // LOGOUT
          _iconBtn(
            icon: Icons.logout_rounded,
            color: _DashTheme.rose,
            bg: _DashTheme.rose.withOpacity(0.08),
            border: _DashTheme.rose.withOpacity(0.2),
            onTap: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 34, // slightly smaller to prevent overflow
          height: 34,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // STATS GRID  — FIX: use childAspectRatio that gives enough height
  // ─────────────────────────────────────────────────
  Widget _buildStatsGrid(_DashTheme t) {
    final stats = [
      _StatData(
        'Total Users',
        '$_totalUsers',
        Icons.people_alt_rounded,
        _DashTheme.accent,
      ),
      _StatData(
        'Admins',
        '$_totalAdmins',
        Icons.admin_panel_settings_rounded,
        _DashTheme.amber,
      ),
      _StatData(
        'Active Today',
        '$_dailyActive',
        Icons.today_rounded,
        _DashTheme.rose,
      ),
      _StatData(
        'Active / Week',
        '$_weeklyActive',
        Icons.date_range_rounded,
        _DashTheme.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio:
            1.55, // FIX: was 1.45, more width-to-height gives card more room
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => _buildStatCard(stats[i], t, i),
    );
  }

  Widget _buildStatCard(_StatData s, _DashTheme t, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 60),
      padding: const EdgeInsets.all(14), // slightly reduced from 16
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: s.color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: s.color.withOpacity(_isDark ? 0.08 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7), // reduced from 8
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  s.icon,
                  color: s.color,
                  size: 16,
                ), // reduced from 18
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: s.color.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // FIX: don't try to expand
            children: [
              Text(
                s.value,
                style: TextStyle(
                  color: t.textPrimary,
                  fontSize: 26, // reduced from 30 to give label room
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.label,
                style: TextStyle(
                  color: t.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // FIX: never wraps
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // MANAGEMENT TILE
  // ─────────────────────────────────────────────────
  Widget _buildManagementTile({
    required _DashTheme t,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: t.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.chevron_right_rounded, color: color, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────────
  Widget _buildSectionLabel(String text, _DashTheme t) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: _DashTheme.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // RECENT USERS
  // ─────────────────────────────────────────────────
  Widget _buildRecentUsers(_DashTheme t) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: _DashTheme.accent,
                strokeWidth: 2,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No users yet.', style: TextStyle(color: t.textMuted)),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['username'] ?? data['name'] ?? 'Unknown';
            final email = data['email'] ?? '';
            final role = data['role'] ?? 'user';
            final isAdmin = role == 'admin';
            final createdAt = data['createdAt'] != null
                ? DateFormat(
                    'MMM d, yyyy',
                  ).format((data['createdAt'] as Timestamp).toDate())
                : 'N/A';
            final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
            final avatarColor = isAdmin ? _DashTheme.amber : _DashTheme.accent;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  // AVATAR
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: avatarColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: avatarColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: avatarColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isAdmin) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _DashTheme.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _DashTheme.amber.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: _DashTheme.amber,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email.isNotEmpty ? email : 'No email',
                          style: TextStyle(
                            color: t.textSecondary,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // DATE
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        createdAt,
                        style: TextStyle(color: t.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────
  // LOADER
  // ─────────────────────────────────────────────────
  Widget _buildLoader(_DashTheme t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: _DashTheme.accent,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading dashboard...',
            style: TextStyle(color: t.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _StatData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}
