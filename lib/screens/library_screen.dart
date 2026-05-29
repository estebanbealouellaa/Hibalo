import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../models/user_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class WordEntry {
  final String filipino;
  final String hiligaynon;
  final String category;
  const WordEntry({
    required this.filipino,
    required this.hiligaynon,
    required this.category,
  });
}

class LessonUnit {
  final String title;
  final String emoji;
  final Color accentColor;
  final List<WordEntry> words;
  bool isUnlocked;
  int completedLessons;

  LessonUnit({
    required this.title,
    required this.emoji,
    required this.accentColor,
    required this.words,
    this.isUnlocked = false,
    this.completedLessons = 0,
  });

  int get totalLessons => (words.length / 4).ceil();
  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
  bool get isCompleted => completedLessons >= totalLessons;
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON DATA
// ─────────────────────────────────────────────────────────────────────────────
List<LessonUnit> _buildUnits() => [
  LessonUnit(
    title: 'Greetings',
    emoji: '👋',
    accentColor: teal300,
    isUnlocked: true,
    completedLessons: 2,
    words: [
      const WordEntry(
        filipino: 'Kamusta',
        hiligaynon: 'Kumusta',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Magandang Umaga',
        hiligaynon: 'Maayong Aga',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Magandang Hapon',
        hiligaynon: 'Maayong Hapon',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Magandang Gabi',
        hiligaynon: 'Maayong Gab-i',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Paalam',
        hiligaynon: 'Paalam / Babay',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Salamat',
        hiligaynon: 'Salamat Gid',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Walang Anuman',
        hiligaynon: 'Wala Sing Anu-ano',
        category: 'Greetings',
      ),
      const WordEntry(
        filipino: 'Kumusta Ka Na',
        hiligaynon: 'Kamusta Ka Na',
        category: 'Greetings',
      ),
    ],
  ),
  LessonUnit(
    title: 'Family',
    emoji: '👨‍👩‍👧',
    accentColor: pink500,
    isUnlocked: true,
    completedLessons: 0,
    words: [
      const WordEntry(
        filipino: 'Nanay',
        hiligaynon: 'Nanay / Iloy',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Tatay',
        hiligaynon: 'Tatay / Amay',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Kapatid',
        hiligaynon: 'Bugto',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Lolo',
        hiligaynon: 'Lolo / Apoy',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Lola',
        hiligaynon: 'Lola / Apoy',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Anak',
        hiligaynon: 'Bata / Anak',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Asawa',
        hiligaynon: 'Asawa',
        category: 'Family',
      ),
      const WordEntry(
        filipino: 'Pamilya',
        hiligaynon: 'Pamilya',
        category: 'Family',
      ),
    ],
  ),
  LessonUnit(
    title: 'Food',
    emoji: '🍚',
    accentColor: purple600,
    isUnlocked: false,
    words: [
      const WordEntry(
        filipino: 'Kanin',
        hiligaynon: 'Kan-on',
        category: 'Food',
      ),
      const WordEntry(filipino: 'Ulam', hiligaynon: 'Sud-an', category: 'Food'),
      const WordEntry(filipino: 'Tubig', hiligaynon: 'Tubig', category: 'Food'),
      const WordEntry(
        filipino: 'Masarap',
        hiligaynon: 'Namit',
        category: 'Food',
      ),
      const WordEntry(filipino: 'Gutom', hiligaynon: 'Gutom', category: 'Food'),
      const WordEntry(filipino: 'Busog', hiligaynon: 'Busog', category: 'Food'),
      const WordEntry(
        filipino: 'Kain Na',
        hiligaynon: 'Kaon Na',
        category: 'Food',
      ),
      const WordEntry(
        filipino: 'Lutuin',
        hiligaynon: 'Lutoon',
        category: 'Food',
      ),
    ],
  ),
  LessonUnit(
    title: 'Animals',
    emoji: '🐾',
    accentColor: purple400,
    isUnlocked: false,
    words: [
      const WordEntry(filipino: 'Aso', hiligaynon: 'Ido', category: 'Animals'),
      const WordEntry(
        filipino: 'Pusa',
        hiligaynon: 'Kuring',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Manok',
        hiligaynon: 'Manok',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Baboy',
        hiligaynon: 'Baboy',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Baka',
        hiligaynon: 'Baka',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Isda',
        hiligaynon: 'Isda',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Ibon',
        hiligaynon: 'Pispis',
        category: 'Animals',
      ),
      const WordEntry(
        filipino: 'Kabayo',
        hiligaynon: 'Kabayo',
        category: 'Animals',
      ),
    ],
  ),
  LessonUnit(
    title: 'Numbers',
    emoji: '🔢',
    accentColor: pink300,
    isUnlocked: false,
    words: [
      const WordEntry(filipino: 'Isa', hiligaynon: 'Isa', category: 'Numbers'),
      const WordEntry(
        filipino: 'Dalawa',
        hiligaynon: 'Duha',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Tatlo',
        hiligaynon: 'Tatlo',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Apat',
        hiligaynon: 'Apat',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Lima',
        hiligaynon: 'Lima',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Anim',
        hiligaynon: 'Anom',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Pito',
        hiligaynon: 'Pito',
        category: 'Numbers',
      ),
      const WordEntry(
        filipino: 'Walo',
        hiligaynon: 'Walo',
        category: 'Numbers',
      ),
    ],
  ),
  LessonUnit(
    title: 'Emotions',
    emoji: '😊',
    accentColor: teal300,
    isUnlocked: false,
    words: [
      const WordEntry(
        filipino: 'Masaya',
        hiligaynon: 'Malipayon',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Malungkot',
        hiligaynon: 'Masulub-on',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Galit',
        hiligaynon: 'Naakig',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Takot',
        hiligaynon: 'Hadlok',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Pagod',
        hiligaynon: 'Kapoy',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Mahal Kita',
        hiligaynon: 'Palangga Ta Ka',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Naiinis',
        hiligaynon: 'Nauyangan',
        category: 'Emotions',
      ),
      const WordEntry(
        filipino: 'Naguguluhan',
        hiligaynon: 'Nagapalibog',
        category: 'Emotions',
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// LIBRARY SCREEN (Modern gradient-based design)
// ─────────────────────────────────────────────────────────────────────────────
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<LessonUnit> _units = _buildUnits();

  void _onLessonComplete(int unitIndex, int xpEarned) {
    final userStats = context.read<UserStats>();

    setState(() {
      _units[unitIndex].completedLessons++;
      if (_units[unitIndex].isCompleted && unitIndex + 1 < _units.length) {
        _units[unitIndex + 1].isUnlocked = true;
      }
    });

    // Update global stats
    userStats.addXp(xpEarned);
    userStats.addWordsLearned(5); // 5 words per lesson
    userStats.completeLesson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [_buildSectionHeader(), ..._buildLessonPath()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TOP BAR ─────────────────────────────────
  Widget _buildTopBar() {
    return Consumer<UserStats>(
      builder: (context, userStats, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.1),
                      Colors.grey.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Text('🇵🇭', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Filipino',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildTopStat('🔥', '${userStats.streak}', teal300),
              const SizedBox(width: 10),
              _buildTopStat('⚡', '${userStats.xp}', pink500),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopStat(String icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ──────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECTION 1',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Basic Filipino & Hiligaynon',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('📖', style: TextStyle(fontSize: 32)),
          ),
        ],
      ),
    );
  }

  // ── LESSON PATH (Asymmetric grid layout) ───────────────────────
  List<Widget> _buildLessonPath() {
    List<Widget> items = [];
    final positions = [0.15, 0.65, 0.25, 0.75, 0.2, 0.7];

    for (int i = 0; i < _units.length; i++) {
      final align = positions[i % positions.length];
      items.add(_buildUnitNode(_units[i], i, align));
      if (i < _units.length - 1) {
        items.add(_buildConnector(_units[i], _units[i + 1]));
      }
    }
    return items;
  }

  Widget _buildUnitNode(LessonUnit unit, int index, double alignFraction) {
    final isLocked = !unit.isUnlocked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment(alignFraction * 2 - 1, 0),
        child: GestureDetector(
          onTap: isLocked
              ? () => _showLockedDialog()
              : () => _showLessonDialog(unit, index),
          child: Column(
            children: [
              if (unit.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('👑', style: TextStyle(fontSize: 18)),
                ),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (!isLocked)
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: unit.accentColor.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLocked
                          ? LinearGradient(
                              colors: [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.2),
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                unit.accentColor,
                                unit.accentColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      border: Border.all(
                        color: isLocked
                            ? Colors.grey.withOpacity(0.3)
                            : unit.accentColor.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(
                              Icons.lock_rounded,
                              color: Colors.black26,
                              size: 28,
                            )
                          : Text(
                              unit.emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                    ),
                  ),
                  if (!isLocked &&
                      !unit.isCompleted &&
                      unit.completedLessons > 0)
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: unit.progress,
                        strokeWidth: 3.5,
                        backgroundColor: unit.accentColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          unit.accentColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                unit.title,
                style: TextStyle(
                  color: isLocked
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              if (!isLocked)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${unit.completedLessons}/${unit.totalLessons} lessons',
                    style: TextStyle(
                      color: unit.accentColor.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnector(LessonUnit current, LessonUnit next) {
    return SizedBox(
      height: 16,
      child: CustomPaint(
        painter: _ConnectorPainter(color: Colors.grey.withOpacity(0.2)),
        child: const SizedBox.expand(),
      ),
    );
  }

  void _showLockedDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Locked',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Complete the previous lesson to unlock this one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
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

  void _showLessonDialog(LessonUnit unit, int unitIndex) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LessonBottomSheet(
        unit: unit,
        onStart: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _LessonScreen(
                unit: unit,
                onComplete: (xp) => _onLessonComplete(unitIndex, xp),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER FOR CONNECTORS
// ─────────────────────────────────────────────────────────────────────────────
class _ConnectorPainter extends CustomPainter {
  final Color color;

  _ConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _LessonBottomSheet extends StatelessWidget {
  final LessonUnit unit;
  final VoidCallback onStart;

  const _LessonBottomSheet({required this.unit, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.withOpacity(0.05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unit.accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(unit.emoji, style: const TextStyle(fontSize: 52)),
          ),
          const SizedBox(height: 20),
          Text(
            unit.title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${unit.words.length} words · ${unit.totalLessons} lessons',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: pink500.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pink500.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⚡', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 8),
                Text(
                  '+20 XP per lesson',
                  style: TextStyle(
                    color: pink500,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: unit.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'START LESSON',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe later',
              style: TextStyle(
                color: Colors.black.withOpacity(0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LESSON SCREEN (Interactive quiz) - UPDATED
// ─────────────────────────────────────────────────────────────────────────────
class _LessonScreen extends StatefulWidget {
  final LessonUnit unit;
  final Function(int xp) onComplete;

  const _LessonScreen({required this.unit, required this.onComplete});

  @override
  State<_LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<_LessonScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _hearts = 3;
  int _xpEarned = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;
  late List<WordEntry> _lessonWords;
  late List<List<String>> _choices;
  late AnimationController _shakeCtrl;
  late AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _lessonWords = widget.unit.words.take(5).toList();
    _choices = _lessonWords.map((w) => _generateChoices(w)).toList();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  List<String> _generateChoices(WordEntry correct) {
    final allWords =
        widget.unit.words
            .where((w) => w.hiligaynon != correct.hiligaynon)
            .toList()
          ..shuffle();
    final wrong = allWords.take(3).map((w) => w.hiligaynon).toList();
    final choices = [...wrong, correct.hiligaynon]..shuffle();
    return choices;
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    HapticFeedback.lightImpact();

    final correct = _lessonWords[_currentIndex].hiligaynon;
    final isCorrect = answer == correct;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _xpEarned += 4;
      _bounceCtrl.forward(from: 0);
    } else {
      _hearts--;
      _shakeCtrl.forward(from: 0);
    }
  }

  void _nextQuestion() {
    if (_hearts <= 0) {
      _showResultScreen(false);
      return;
    }

    if (_currentIndex + 1 >= _lessonWords.length) {
      _showResultScreen(true);
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
      _isCorrect = false;
    });
  }

  void _showResultScreen(bool passed) {
    if (passed) widget.onComplete(_xpEarned);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          passed: passed,
          xpEarned: _xpEarned,
          unit: widget.unit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _lessonWords[_currentIndex];
    final progress = (_currentIndex + 1) / _lessonWords.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              _buildLessonTopBar(progress),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Ano ang Hiligaynon ng...',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedBuilder(
                        animation: _shakeCtrl,
                        builder: (context, child) {
                          final shake = _shakeCtrl.value <= 0.5
                              ? _shakeCtrl.value * 20 - 5
                              : (1 - _shakeCtrl.value) * 20 - 5;
                          return Transform.translate(
                            offset: Offset(shake, 0),
                            child: child,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _answered
                                  ? _isCorrect
                                        ? teal300.withOpacity(0.5)
                                        : pink500.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              word.filipino,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Piliin ang tamang sagot:',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...(_choices[_currentIndex].map(
                        (choice) => _buildChoiceButton(choice, word.hiligaynon),
                      )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (_answered) _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonTopBar(double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close_rounded,
              color: Colors.black.withOpacity(0.4),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.unit.accentColor,
                ),
                minHeight: 11,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Row(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  i < _hearts ? '❤️' : '🖤',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String choice, String correct) {
    Color borderColor = Colors.grey.withOpacity(0.3);
    Color bgColor = Colors.grey.withOpacity(0.05);
    Color textColor = Colors.black87;

    if (_answered && _selectedAnswer == choice) {
      if (_isCorrect) {
        borderColor = teal300.withOpacity(0.5);
        bgColor = teal300.withOpacity(0.1);
        textColor = teal300;
      } else {
        borderColor = pink500.withOpacity(0.5);
        bgColor = pink500.withOpacity(0.1);
        textColor = pink500;
      }
    } else if (_answered && choice == correct) {
      borderColor = teal300.withOpacity(0.4);
      bgColor = teal300.withOpacity(0.08);
      textColor = teal300;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                choice,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_answered && choice == correct)
              Icon(Icons.check_circle_rounded, color: teal300, size: 21),
            if (_answered && _selectedAnswer == choice && !_isCorrect)
              Icon(Icons.cancel_rounded, color: pink500, size: 21),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _isCorrect ? '✅ Tama!' : '❌ Mali!',
                style: TextStyle(
                  color: _isCorrect ? teal300 : pink500,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isCorrect) ...[
                const SizedBox(width: 10),
                Text(
                  '⚡ +4 XP',
                  style: TextStyle(
                    color: pink300,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                const Spacer(),
                Text(
                  'Sagot: ${_lessonWords[_currentIndex].hiligaynon}',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCorrect ? teal300 : pink500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'ITULOY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESULT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _ResultScreen extends StatelessWidget {
  final bool passed;
  final int xpEarned;
  final LessonUnit unit;

  const _ResultScreen({
    required this.passed,
    required this.xpEarned,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(passed ? '🎉' : '💔', style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 28),
              Text(
                passed ? 'Napakahusay!' : 'Subukan Ulit!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                passed
                    ? 'Natapos mo ang ${unit.title} lesson!'
                    : 'Huwag sumuko, practice makes perfect!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 44),

              if (passed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('⚡', '+$xpEarned XP', pink500),
                    _buildStat('🔥', 'Streak!', teal300),
                    _buildStat('⭐', 'Excellent', purple400),
                  ],
                ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: passed ? teal300 : purple600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    passed ? 'MAGPATULOY' : 'SUBUKAN ULIT',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.8,
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

  Widget _buildStat(String icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
