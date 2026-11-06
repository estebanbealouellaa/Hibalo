import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_avatar.dart';

/// Saves the username and avatar (photoUrl "asset:avatarN") to Firebase
/// Auth and users/{uid}, as before.
Future<void> saveProfileToFirebase(String username, String photoUrl) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Not logged in.');
  await user.updateDisplayName(username);
  try {
    await user.updatePhotoURL(photoUrl);
  } catch (e) {
    // The Firestore value below is the one the app reads.
    debugPrint('[Profile] photoURL not updated: $e');
  }
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'username': username,
    'photoUrl': photoUrl,
  }, SetOptions(merge: true));
  await user.reload();
}

/// Edit profile (Figma 608:5354 / 618:6102, error 608:5500): the avatar row
/// and the username. Email, password, Forgot password and Delete account are
/// hidden for now (extra #11). Closes with true after saving.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.currentUsername, this.currentPhotoUrl, this.save});

  final String currentUsername;
  final String? currentPhotoUrl;

  /// For tests; [saveProfileToFirebase] when null.
  final Future<void> Function(String username, String photoUrl)? save;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _username = TextEditingController(text: widget.currentUsername);

  /// The chosen avatar (0–5); an old DiceBear picture starts on its slot.
  late int _avatar = avatarIndexOf(widget.currentPhotoUrl) ?? 0;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _username.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Username cannot be empty.');
      return;
    }
    if (name.length < 3) {
      setState(() => _error = 'Username must be at least 3 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await (widget.save ?? saveProfileToFirebase)(name, avatarValue(_avatar));
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showV6Snackbar(context, "Couldn't save. Please try again.", icon: Icons.error_rounded);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: 'Edit profile', onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text('Choose an avatar', style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var i = 0; i < kAvatarCount; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: _AvatarTile(
                            index: i,
                            selected: i == _avatar,
                            onTap: () => setState(() => _avatar = i),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Account', style: V6Text.titleMediumBold),
                  const SizedBox(height: 12),
                  V6TextField(
                    label: 'Username',
                    controller: _username,
                    prefixIcon: Icons.person_rounded,
                    maxLength: 30,
                    errorText: _error,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    onSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 24),
                  V6Button(label: 'Save changes', expand: true, loading: _saving, onPressed: _save),
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
  const _AvatarTile({required this.index, required this.selected, required this.onTap});

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Avatar ${index + 1}',
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
