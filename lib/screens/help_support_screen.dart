import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';

// ── FAQ Data ──────────────────────────────────────────────────────────────────
const List<Map<String, String>> kFaqs = [
  {
    'q': 'Ano ang Hibalo?',
    'a':
        'Ang Hibalo ay isang app na tumutulong sa pag-aaral ng Hiligaynon at Filipino. '
        'Nagbibigay ito ng real-time na pagsasalin, mga laro, at mga pagsubok para '
        'matulungan kang matuto nang mas mabilis at masaya.',
  },
  {
    'q': 'Paano gumagana ang real-time translator?',
    'a':
        'I-tap lang ang mikropono at magsalita sa Hiligaynon o Filipino. '
        'Awtomatiko itong isasalin ng app. Maaari ka ring mag-type ng teksto '
        'para sa pagsasalin.',
  },
  {
    'q': 'Libre ba ang Hibalo?',
    'a':
        'Oo! Ang Hibalo ay ganap na libre. Lahat ng features — translator, '
        'vocabulary lessons, at quizzes — ay available nang walang bayad.',
  },
  {
    'q': 'Paano ko maaayos ang aking streak?',
    'a':
        'Ang streak ay nare-reset kapag hindi ka nag-aral ng kahit isang araw. '
        'Para mapanatili ito, subukang mag-complete ng kahit isang quiz o '
        'vocabulary lesson araw-araw.',
  },
  {
    'q': 'Paano ko mababago ang aking username o avatar?',
    'a':
        'Pumunta sa Profile → Edit Profile. Doon mo mababago ang iyong username '
        'at mapipili ang iyong gusto na avatar.',
  },
  {
    'q': 'Hindi gumagana ang speech recognition. Ano ang gagawin ko?',
    'a':
        'Siguraduhing binigyan mo ng permiso ang app na gamitin ang mikropono. '
        'Pumunta sa Settings ng iyong phone → Apps → Hibalo → Permissions '
        '→ i-enable ang Microphone.',
  },
];

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'hibalo@gmail.com',
      queryParameters: {'subject': 'Hibalo App - Support Request'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hindi mabukas ang email app.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: pink500,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFaqTab(), _buildContactTab()],
      ),
    );
  }

  // ── FAQ Tab ───────────────────────────────────────────────────────────────
  Widget _buildFaqTab() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: kFaqs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final faq = kFaqs[index];
        return _FaqItem(question: faq['q']!, answer: faq['a']!);
      },
    );
  }

  // ── Contact Us Tab ────────────────────────────────────────────────────────
  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          // ── Illustration ──────────────────────────────────────────────────
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: purple600.withOpacity(0.3),
              border: Border.all(color: purple400.withOpacity(0.3), width: 2),
            ),
            child: const Center(
              child: Text('💌', style: TextStyle(fontSize: 48)),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Kumusta ka?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'May katanungan o feedback? Huwag mag-atubiling makipag-ugnayan sa amin. '
            'Tutugon kami sa lalong madaling panahon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 36),

          // ── Email card ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: purple800.withOpacity(0.6),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: purple600.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: pink500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.email_rounded, color: pink500, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'hibalo@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Send email button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'Mag-email sa amin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pink500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Response time note ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: purple800.withOpacity(0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: purple600.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Karaniwang tumutugon kami sa loob ng 1–2 araw na trabaho.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Item widget (expandable) ──────────────────────────────────────────────
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconTurn = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _expanded
              ? purple600.withOpacity(0.25)
              : purple800.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _expanded
                ? purple400.withOpacity(0.5)
                : purple600.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _iconTurn,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 22,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.answer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
