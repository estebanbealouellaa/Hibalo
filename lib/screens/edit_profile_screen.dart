import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';

// ── 6 DiceBear "fun-emoji" avatars (PNG via DiceBear API) ─────────────────
// Each seed produces a unique cute illustrated character — no Storage needed.
const List<Map<String, String>> kAvatars = [
  {
    'id': 'avatar_1',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Lilly&size=128',
  },
  {
    'id': 'avatar_2',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Felix&size=128',
  },
  {
    'id': 'avatar_3',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Mochi&size=128',
  },
  {
    'id': 'avatar_4',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Coco&size=128',
  },
  {
    'id': 'avatar_5',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Kiki&size=128',
  },
  {
    'id': 'avatar_6',
    'url': 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Boba&size=128',
  },
];

class EditProfileScreen extends StatefulWidget {
  final String currentUsername;
  final String? currentPhotoUrl;

  final void Function(String newUsername, String? newPhotoUrl) onSaved;

  const EditProfileScreen({
    super.key,
    required this.currentUsername,
    this.currentPhotoUrl,
    required this.onSaved,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  String? _selectedAvatarUrl;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
    // Keep existing avatar if it matches one of ours; else default to first
    _selectedAvatarUrl = kAvatars.any((a) => a['url'] == widget.currentPhotoUrl)
        ? widget.currentPhotoUrl
        : kAvatars.first['url'];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ── Save changes ──────────────────────────────────────────────────────────
  Future<void> _save() async {
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      setState(() => _errorMessage = 'Username cannot be empty.');
      return;
    }
    if (newUsername.length < 3) {
      setState(() => _errorMessage = 'Username must be at least 3 characters.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in.');

      await user.updateDisplayName(newUsername);
      await user.updatePhotoURL(_selectedAvatarUrl);

      widget.onSaved(newUsername, _selectedAvatarUrl);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple900,
      appBar: AppBar(
        backgroundColor: purple900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Current selected avatar preview ────────────────────────────
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: purple400, width: 3),
                  color: purple800,
                ),
                child: ClipOval(
                  child: Image.network(
                    _selectedAvatarUrl ?? kAvatars.first['url']!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Avatar picker label ────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose Avatar',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── 6 Avatar grid ──────────────────────────────────────────────
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: kAvatars.length,
                itemBuilder: (context, index) {
                  final avatar = kAvatars[index];
                  final isSelected = _selectedAvatarUrl == avatar['url'];

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedAvatarUrl = avatar['url']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? pink500
                              : purple600.withOpacity(0.3),
                          width: isSelected ? 3 : 1.5,
                        ),
                        color: isSelected
                            ? pink500.withOpacity(0.12)
                            : purple800.withOpacity(0.5),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.network(
                              avatar['url']!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                          // Checkmark overlay when selected
                          if (isSelected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: pink500,
                                  size: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── Username field ────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Username',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _usernameController,
                maxLength: 30,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  counterStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: purple400,
                  ),
                  filled: true,
                  fillColor: purple800.withOpacity(0.6),
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: purple600.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: purple600.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: purple400, width: 1.5),
                  ),
                ),
              ),

              // ── Error message ─────────────────────────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              // ── Save button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple400,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: purple600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
}
