import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../learning/sync/firestore_progress_cloud.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_avatar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // Filter: 'all' | 'admin' | 'user'
  String _roleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V6Colors.background,
      appBar: AppBar(
        backgroundColor: V6Colors.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).adminManageUsers,
          style: TextStyle(color: V6Colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: V6Colors.textPrimary),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: V6Colors.textPrimary),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).adminSearch,
                hintStyle: const TextStyle(color: V6Colors.textMuted),
                prefixIcon: const Icon(Icons.search, color: V6Colors.textMuted),
                filled: true,
                fillColor: V6Colors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          // ── Role filter chips ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['all', 'user', 'admin'].map((f) {
                final selected = _roleFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f == 'all' ? AppLocalizations.of(context).adminAll : f.capitalize()),
                    selected: selected,
                    selectedColor: V6Colors.primary.withValues(alpha: 0.25),
                    backgroundColor: V6Colors.surface,
                    labelStyle: TextStyle(
                      color: selected
                          ? V6Colors.primary
                          : V6Colors.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: selected
                          ? V6Colors.primary
                          : V6Colors.borderDivider,
                    ),
                    onSelected: (_) => setState(() => _roleFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          // ── Users list ──────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: V6Colors.primary),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final role = (data['role'] ?? 'user').toString();

                  final matchesSearch =
                      _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                  final matchesRole =
                      _roleFilter == 'all' || role == _roleFilter;

                  return matchesSearch && matchesRole;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context).adminNoUsersFound,
                      style: TextStyle(color: V6Colors.textMuted),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _userTile(doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _userTile(String uid, Map<String, dynamic> data) {
    final name = data['name'] ?? AppLocalizations.of(context).adminNoName;
    final email = data['email'] ?? AppLocalizations.of(context).adminNoEmailCap;
    final role = data['role'] ?? 'user';
    final isAdmin = role == 'admin';

    return Container(
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAdmin
              ? V6Colors.warning.withValues(alpha: 0.25)
              : V6Colors.borderDivider,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Stack(
          children: [
            if ((data['photoUrl'] as String?)?.isNotEmpty ?? false)
              V6Avatar(photoUrl: data['photoUrl'] as String?, size: 44)
            else
            CircleAvatar(
              radius: 22,
              backgroundColor: isAdmin
                  ? V6Colors.warning.withValues(alpha: 0.15)
                  : V6Colors.primary.withValues(alpha: 0.15),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isAdmin
                      ? V6Colors.warning
                      : V6Colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isAdmin)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: V6Colors.warning,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 9,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: V6Colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(color: V6Colors.textMuted, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          color: V6Colors.surfaceTint,
          icon: const Icon(Icons.more_vert, color: V6Colors.textMuted),
          onSelected: (action) => _handleAction(action, uid, data),
          itemBuilder: (_) => [
            _menuItem('edit', Icons.edit_rounded, AppLocalizations.of(context).adminEdit),
            _menuItem(
              isAdmin ? 'demote' : 'promote',
              isAdmin
                  ? Icons.remove_moderator_rounded
                  : Icons.admin_panel_settings_rounded,
              isAdmin ? AppLocalizations.of(context).adminRemoveAdmin : AppLocalizations.of(context).adminMakeAdmin,
            ),
            _menuItem(
              'delete',
              Icons.delete_rounded,
              AppLocalizations.of(context).adminDelete,
              destructive: true,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? V6Colors.error : V6Colors.textSecondary;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }

  void _handleAction(String action, String uid, Map<String, dynamic> data) {
    switch (action) {
      case 'edit':
        _showEditDialog(uid, data);
        break;
      case 'promote':
        _updateUser(uid, {'role': 'admin'}, AppLocalizations.of(context).adminPromoted);
        break;
      case 'demote':
        _updateUser(uid, {'role': 'user'}, AppLocalizations.of(context).adminDemoted);
        break;
      case 'delete':
        _confirmDelete(uid, data['name'] ?? 'this user');
        break;
    }
  }

  Future<void> _updateUser(
    String uid,
    Map<String, dynamic> fields,
    String successMsg,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      await _firestore.collection('users').doc(uid).update(fields);
      _showSnack(successMsg);
    } catch (e) {
      _showSnack(l10n.adminError(e), error: true);
    }
  }

  void _showEditDialog(String uid, Map<String, dynamic> data) {
    final nameCtrl = TextEditingController(text: data['name'] ?? '');
    final emailCtrl = TextEditingController(text: data['email'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: V6Colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context).adminEditUser,
          style: TextStyle(color: V6Colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(nameCtrl, AppLocalizations.of(context).adminName, Icons.person_rounded),
            const SizedBox(height: 12),
            _field(emailCtrl, AppLocalizations.of(context).commonEmail, Icons.email_rounded),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: TextStyle(color: V6Colors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: V6Colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _updateUser(uid, {
                'name': nameCtrl.text.trim(),
                'email': emailCtrl.text.trim(),
              }, AppLocalizations.of(context).adminUserUpdated);
            },
            child: Text(AppLocalizations.of(context).commonSave, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: V6Colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: V6Colors.textSecondary),
        prefixIcon: Icon(icon, color: V6Colors.textMuted, size: 20),
        filled: true,
        fillColor: V6Colors.surfaceTint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _confirmDelete(String uid, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: V6Colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context).adminDeleteUser,
          style: TextStyle(
            color: V6Colors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppLocalizations.of(context).adminDeleteConfirm(name),
          style: const TextStyle(color: V6Colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: TextStyle(color: V6Colors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: V6Colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final l10n = AppLocalizations.of(context);
              Navigator.pop(context);
              try {
                // The user's learning progress first (lessonProgress and
                // quizAttempts), then the user document, in the last batch.
                await FirestoreProgressCloud.deleteLearningDocs(
                  _firestore,
                  uid,
                  also: (batch) => batch.delete(_firestore.collection('users').doc(uid)),
                );
                _showSnack(l10n.adminUserDeleted);
              } catch (e) {
                _showSnack(l10n.adminError(e), error: true);
              }
            },
            child: Text(AppLocalizations.of(context).adminDelete, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? V6Colors.error : V6Colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ── Usage Analytics Screen ──────────────────────────────────────────────────

class AdminUsageScreen extends StatefulWidget {
  const AdminUsageScreen({super.key});

  @override
  State<AdminUsageScreen> createState() => _AdminUsageScreenState();
}

class _AdminUsageScreenState extends State<AdminUsageScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> _dailyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, int> data = {};
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final start = DateTime(day.year, day.month, day.day);
        final end = start.add(const Duration(days: 1));
        final snap = await _firestore
            .collection('users')
            .where(
              'lastActive',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            )
            .where('lastActive', isLessThan: Timestamp.fromDate(end))
            .get();
        data['${day.month}/${day.day}'] = snap.size;
      }
      setState(() {
        _dailyData = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V6Colors.background,
      appBar: AppBar(
        backgroundColor: V6Colors.surface,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).adminUsage,
          style: TextStyle(color: V6Colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: V6Colors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: V6Colors.textSecondary),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: V6Colors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).adminDailyActive,
                    style: TextStyle(
                      color: V6Colors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _barChart(),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).adminBreakdown,
                    style: TextStyle(
                      color: V6Colors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._dailyData.entries.map(
                    (e) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: V6Colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(color: V6Colors.textSecondary),
                          ),
                          Text(
                            AppLocalizations.of(context).adminActiveCount(e.value),
                            style: const TextStyle(
                              color: V6Colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _barChart() {
    final entries = _dailyData.entries.toList();
    final maxVal = entries.isEmpty
        ? 1
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 180,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.map((entry) {
            final pct = maxVal == 0 ? 0.0 : entry.value / maxVal;
            final barHeight = (pct * 130).clamp(4.0, 130.0);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: V6Colors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [V6Colors.primary, V6Colors.primaryContainer],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: V6Colors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Simple extension so 'admin'.capitalize() → 'Admin'
extension StringCap on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
