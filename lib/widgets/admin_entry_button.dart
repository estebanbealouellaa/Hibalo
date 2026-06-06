import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app; // ← PREFIX ADDED
import '../screens/admin_dashboard_screen.dart';

/// Placed above the avatar inside the purple header card.
/// Invisible to regular users — only renders when role == 'admin'.
class AdminEntryButton extends StatelessWidget {
  const AdminEntryButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<app.AuthProvider>().isAdmin; // ← PREFIXED

    if (!isAdmin) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(
            onLogout: () => Navigator.pop(context), // ← onLogout ADDED
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white54),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
