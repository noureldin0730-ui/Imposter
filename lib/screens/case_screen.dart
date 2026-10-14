import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cases_data.dart';
import '../data/generators.dart';
import '../data/save_manager.dart';
import 'accuse_screen.dart';

class P {
  static const bg = Color(0xFF0A0807);
  static const dark = Color(0xFF141110);
  static const dim = Color(0xFF6A5A55);
  static const mid = Color(0xFF8B1A1A);
  static const rare = Color(0xFFC1272D);
  static const white = Color(0xFFE8E2DD);
  static const gold = Color(0xFFB8945C);
}

class CaseScreen extends StatefulWidget {
  final int caseId;
  const CaseScreen({super.key, required this.caseId});

  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen>
    with SingleTickerProviderStateMixin {
  late Case _case;
  late TabController _tabs;
  int _wrongAttempts = 0;

  @override
  void initState() {
    super.initState();
    _case = getCase(widget.caseId);
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ═══════════════ حساب النجوم ═══════════════
  int _calculateStars() {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts == 1) return 2;
    return 1;
  }

  Future<void> _onAccuse(String suspectName) async {
    final isCorrect = suspectName == _case.killer;
    if (isCorrect) {
      HapticFeedback.lightImpact();

      // ═══ احفظ النجوم الحقيقية ═══
      final stars = _calculateStars();
      await SaveManager.setStars(_case.id, stars);

      if (_case.id < kTotalCases) {
        await SaveManager.unlock(_case.id + 1);
        await SaveManager.setCurrentCase(_case.id + 1);
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AccuseScreen(
            caseData: _case,
            accused: suspectName,
            correct: true,
            stars: stars,
          ),
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      // ═══ خصم محاولة ═══
      setState(() => _wrongAttempts++);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AccuseScreen(
            caseData: _case,
            accused: suspectName,
            correct: false,
            stars: 0,
          ),
        ),
      );
    }
  }

  void _openAccuseMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: P.dark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AccuseSheet(
        suspects: _case.suspects,
        onPick: (name) {
          Navigator.of(context).pop();
          _onAccuse(name);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: P.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: P.dim,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'القضية ${_case.id} من $kTotalCases',
                          style: const TextStyle(
                            color: P.rare,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _case.title,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ═══ عرض المحاولات ═══
                  if (_wrongAttempts > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: P.rare),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: P.rare,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'محاولات غلط: $_wrongAttempts',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: P.rare,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1A1A1A), height: 1),
            Container(
              color: P.dark,
              child: TabBar(
                controller: _tabs,
                isScrollable: true,
                labelColor: P.rare,
                unselectedLabelColor: P.dim,
                indicatorColor: P.rare,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'الجريمة'),
                  Tab(text: 'الضحية'),
                  Tab(text: 'المشتبه بهم'),
                  Tab(text: 'الأدلة'),
                  Tab(text: 'شهادات'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _CrimeTab(c: _case),
                  _VictimTab(c: _case),
                  _SuspectsTab(c: _case),
                  _EvidenceTab(c: _case),
                  _TestimonyTab(c: _case),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0807),
                border: Border(
                  top: BorderSide(color: Color(0xFF1A1A1A)),
                ),
              ),
              child: GestureDetector(
                onTap: _openAccuseMenu,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: P.mid,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: P.rare.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Text(
                    'اتهم المشتبه به',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: P.white,
                      fontSize: 16,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
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
}

// ═══════════════ تاب الجريمة ═══════════════
class _CrimeTab extends StatelessWidget {
  final Case c;
  const _CrimeTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBlock(
            icon: Icons.location_on,
            label: 'المكان',
            value: c.location,
          ),
          const SizedBox(height: 14),
          _InfoBlock(
            icon: Icons.access_time,
            label: 'الوقت',
            value: c.time,
          ),
          const SizedBox(height: 24),
          const Text(
            'وصف الجريمة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.rare,
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            c.crimeScene,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: P.white,
              fontSize: 15,
              height: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════ تاب الضحية ═══════════════
class _VictimTab extends StatelessWidget {
  final Case c;
  const _VictimTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: P.dark,
          border: Border.all(color: P.mid.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: P.mid, width: 2),
                  ),
                  child: const Icon(Icons.person, color: P.mid),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.victim.name,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: P.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${c.victim.age} سنة • ${c.victim.job}',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: P.dim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF1A1A1A)),
            const SizedBox(height: 12),
            Text(
              c.victim.description,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.white,
                fontSize: 14,
                height: 1.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════ تاب المشتبه بهم ═══════════════
class _SuspectsTab extends StatelessWidget {
  final Case c;
  const _SuspectsTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: c.suspects.length,
      itemBuilder: (context, i) {
        final s = c.suspects[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: P.dark,
            border: Border.all(color: P.mid.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: P.mid, width: 1.5),
                    ),
                    child: Text(
                      s.name.substring(0, 1),
                      style: const TextStyle(
                        color: P.rare,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${s.age} سنة • ${s.relation}',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.dim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF1A1A1A), height: 1),
              const SizedBox(height: 12),
              _label('القصة'),
              const SizedBox(height: 6),
              Text(
                s.story,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.white,
                  fontSize: 13,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 12),
              _label('الحجة (Alibi)'),
              const SizedBox(height: 6),
              Text(
                s.alibi,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.gold,
                  fontSize: 13,
                  height: 1.8,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String t) {
    return Text(
      t,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        color: P.rare,
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ═══════════════ تاب الأدلة ═══════════════
class _EvidenceTab extends StatelessWidget {
  final Case c;
  const _EvidenceTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: c.evidences.length,
      itemBuilder: (context, i) {
        final e = c.evidences[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: P.dark,
            border: Border.all(color: P.gold.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: P.gold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      e.title,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                e.detail,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.white,
                  fontSize: 13,
                  height: 1.9,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════ تاب الشهادات ═══════════════
class _TestimonyTab extends StatelessWidget {
  final Case c;
  const _TestimonyTab({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: c.testimonies.length,
      itemBuilder: (context, i) {
        final t = c.testimonies[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: P.dark,
            border: Border.all(color: P.mid.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: P.mid,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.speaker,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: P.rare,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '"${t.text}"',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: P.white,
                  fontSize: 14,
                  height: 1.9,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════ شرائح صغيرة ═══════════════
class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: P.mid, size: 18),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: P.dim,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: P.white, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════ شيت الاتهام ═══════════════
class _AccuseSheet extends StatelessWidget {
  final List<Suspect> suspects;
  final void Function(String) onPick;
  const _AccuseSheet({required this.suspects, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مين القاتل؟',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: P.rare,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'لو غلط، هترجع تقرأ تاني',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: P.dim, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ...suspects.map((s) {
            return GestureDetector(
              onTap: () => onPick(s.name),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: P.bg,
                  border: Border.all(color: P.mid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: P.mid, width: 1.5),
                      ),
                      child: Text(
                        s.name.substring(0, 1),
                        style: const TextStyle(
                          color: P.rare,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        s.name,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: P.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}