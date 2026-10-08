import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/hibalo_ui.dart'; // hibaloProfileHeroGradient
import 'library_screen.dart'; // Gamify, LessonProgress, learningLevels
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;

  /// Fallback only. The real streak comes from Gamify, so the number here
  /// always matches the one on the lessons screen.
  final int dayStreak;

  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.dayStreak,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  late String _displayName;
  String? _photoUrl;

  int _streak = 0;
  int _xp = 0;

  /// Sections finished, per lesson id.
  final Map<String, int> _done = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final user = FirebaseAuth.instance.currentUser;
    _displayName = user?.displayName ?? widget.userName;
    _photoUrl = user?.photoURL;
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The streak can roll over while the app sits in the background.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final streak = await Gamify.streak();
    final xp = await Gamify.xp();
    final done = <String, int>{};
    for (final level in learningLevels) {
      for (final lesson in level.lessons) {
        done[lesson.id] = await LessonProgress.load(lesson.id);
      }
    }
    if (!mounted) return;
    setState(() {
      _streak = streak > 0 ? streak : widget.dayStreak;
      _xp = xp;
      _done
        ..clear()
        ..addAll(done);
      _loaded = true;
    });
  }

  // ── Progress helpers ────────────────────────────────────────────────────
  int _doneFor(Lesson l) => (_done[l.id] ?? 0).clamp(0, l.sections.length);

  int _sectionsDone(LearningLevel lv) =>
      lv.lessons.fold(0, (s, l) => s + _doneFor(l));

  int _lessonsDone(LearningLevel lv) =>
      lv.lessons.where((l) => _doneFor(l) >= l.sections.length).length;

  bool _finished(LearningLevel lv) =>
      lv.lessons.isNotEmpty && _sectionsDone(lv) >= lv.totalSections;

  bool _unlocked(int i) => i == 0 || _finished(learningLevels[i - 1]);

  /// The level the learner is on now, used for the badge under their name.
  LearningLevel get _currentLevel {
    for (int i = 0; i < learningLevels.length; i++) {
      if (_unlocked(i) && !_finished(learningLevels[i])) {
        return learningLevels[i];
      }
    }
    return learningLevels.last;
  }

  bool get _allDone => learningLevels.every(_finished);

  double get _overall {
    final total = learningLevels.fold<int>(0, (s, lv) => s + lv.totalSections);
    if (total == 0) return 0;
    final done = learningLevels.fold<int>(0, (s, lv) => s + _sectionsDone(lv));
    return (done / total).clamp(0.0, 1.0);
  }

  int get _lessonsFinished =>
      learningLevels.fold(0, (s, lv) => s + _lessonsDone(lv));

  // ── Actions ─────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Log out?'),
        content: const Text(
          'Your progress is saved. You can sign back in any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out', style: TextStyle(color: logoutRed)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
  }

  Future<void> _openEditProfile() async {
    HapticFeedback.lightImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentUsername: _displayName,
          currentPhotoUrl: _photoUrl,
          onSaved: (newUsername, newPhotoUrl) {
            setState(() {
              _displayName = newUsername;
              _photoUrl = newPhotoUrl;
            });
          },
        ),
      ),
    );
    _refresh();
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: RefreshIndicator(
        color: purple,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              _hero(),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Column(
                  children: [
                    _statsCard(),
                    const SizedBox(height: 22),
                    _journey(),
                    const SizedBox(height: 22),
                    _menu(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────
  Widget _hero() {
    final level = _currentLevel;
    final badge = _allDone ? 'All levels complete' : level.name;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 20,
          24,
          54,
        ),
        decoration: const BoxDecoration(gradient: hibaloProfileHeroGradient),
        child: Row(
          children: [
            // Avatar with a progress ring showing the whole course.
            SizedBox(
              width: 76,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _overall),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: v,
                        strokeWidth: 4,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: ClipOval(child: _avatarWidget()),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.displayMedium.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _allDone
                                  ? Icons.workspace_premium_rounded
                                  : Icons.school_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_overall * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _openEditProfile,
              tooltip: 'Edit profile',
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats: streak, XP, lessons ──────────────────────────────────────────
  Widget _statsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFFF7A3D),
            value: '$_streak',
            label: _streak == 1 ? 'Day streak' : 'Day streak',
            hint: _streak == 0 ? 'Start today' : null,
          ),
          _statDivider(),
          _statItem(
            icon: Icons.bolt_rounded,
            color: const Color(0xFFFFB020),
            value: '$_xp',
            label: 'Total XP',
          ),
          _statDivider(),
          _statItem(
            icon: Icons.menu_book_rounded,
            color: purple,
            value: '$_lessonsFinished',
            label: 'Lessons done',
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    String? hint,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            _loaded ? value : '—',
            style: AppTheme.displaySmall.copyWith(fontSize: 22, color: ink),
          ),
          const SizedBox(height: 2),
          Text(
            hint ?? label,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(width: 1, height: 46, color: borderLight);

  // ── Journey: one row per level ──────────────────────────────────────────
  Widget _journey() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text('MY JOURNEY', style: AppTheme.labelCaps),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < learningLevels.length; i++)
                  _levelRow(i, learningLevels[i]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelRow(int i, LearningLevel lv) {
    final unlocked = _unlocked(i);
    final finished = _finished(lv);
    final total = lv.totalSections;
    final doneSections = _sectionsDone(lv);
    final progress = total == 0 ? 0.0 : (doneSections / total).clamp(0.0, 1.0);
    final isCurrent = unlocked && !finished && lv.lessons.isNotEmpty;

    final accent = finished
        ? const Color(0xFF3BB78F)
        : unlocked
        ? lv.colors.first
        : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? lv.colors.first.withOpacity(0.06) : null,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Badge: the level's rung on the ladder.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: unlocked
                  ? LinearGradient(
                      colors: finished
                          ? [const Color(0xFF3BB78F), const Color(0xFF69D6A8)]
                          : lv.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: unlocked ? null : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              finished
                  ? Icons.check_rounded
                  : unlocked
                  ? Icons.play_arrow_rounded
                  : Icons.lock_rounded,
              color: unlocked ? Colors.white : Colors.grey.shade500,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      lv.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: unlocked ? ink : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: lv.colors.first.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'In progress',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: lv.colors.first,
                          ),
                        ),
                      )
                    else if (finished)
                      const Text('🏅', style: TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  !unlocked
                      ? 'Finish ${learningLevels[i - 1].name} to unlock'
                      : lv.lessons.isEmpty
                      ? 'Lessons coming soon'
                      : '${_lessonsDone(lv)} of ${lv.lessons.length} lessons',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 11.5),
                ),
                if (unlocked && lv.lessons.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 6,
                        backgroundColor: accent.withOpacity(0.14),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            unlocked && lv.lessons.isNotEmpty
                ? '${(progress * 100).round()}%'
                : '',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu ────────────────────────────────────────────────────────────────
  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text('MY ACCOUNT', style: AppTheme.labelCaps),
          ),
          _menuItem(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Name, photo, preferences',
            onTap: _openEditProfile,
          ),
          _menuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'FAQ, contact us',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: logoutRed.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: logoutRed.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: logoutRed, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Log out',
                    style: AppTheme.bodyLarge.copyWith(
                      color: logoutRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: purple.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: purplePale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: purple, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: purpleMid, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────────────────
  Widget _avatarWidget() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(
        _photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialAvatar(),
      );
    }
    return _initialAvatar();
  }

  Widget _initialAvatar() => Image.asset(
    'assets/Account.png',
    width: 62,
    height: 62,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      alignment: Alignment.center,
      color: Colors.white.withOpacity(0.2),
      child: Text(
        _displayName.isEmpty ? '?' : _displayName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}
