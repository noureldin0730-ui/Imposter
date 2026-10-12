import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cases_data.dart';
import '../data/save_manager.dart';
import 'case_screen.dart';

class P {
  static const bg = Color(0xFF0A0807);
  static const dark = Color(0xFF141110);
  static const dim = Color(0xFF6A5A55);
  static const mid = Color(0xFF8B1A1A);
  static const rare = Color(0xFFC1272D);
  static const white = Color(0xFFE8E2DD);
  static const gold = Color(0xFFB8945C);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<int, int> _stars = {};
  int _currentCase = 1;
  int _totalStars = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stars = await SaveManager.getStars();
    final current = await SaveManager.getCurrentCase();
    final total = await SaveManager.getTotalStars();
    if (!mounted) return;
    setState(() {
      _stars = stars;
      _currentCase = current;
      _totalStars = total;
      _loading = false;
    });
  }

  Future<void> _openCase(int caseId) async {
    final unlocked = await SaveManager.isUnlocked(caseId);
    if (!unlocked) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حل القضية اللي قبلها الأول',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: P.mid,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CaseScreen(caseId: caseId)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: P.bg,
        body: Center(child: CircularProgressIndicator(color: P.mid)),
      );
    }

    return Scaffold(
      backgroundColor: P.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ────── الشريط العلوي ──────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: P.dim,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: P.gold.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: P.gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$_totalStars / ${kCases.length * 3}',
                          style: const TextStyle(
                            color: P.gold,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'IMPOSTER',
                    style: TextStyle(
                      color: P.rare,
                      fontSize: 13,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1A1A1A), height: 1),

            // ────── القضايا ──────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                itemCount: kCases.length,
                itemBuilder: (context, index) {
                  final c = kCases[index];
                  final stars = _stars[c.id] ?? 0;
                  final offset = _zigzagOffset(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: Alignment(offset, 0),
                      child: _CaseNode(
                        caseId: c.id,
                        title: c.title,
                        stars: stars,
                        isCurrent: c.id == _currentCase,
                        onTap: () => _openCase(c.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _zigzagOffset(int index) {
    final pattern = [0.0, -0.4, -0.7, -0.4, 0.0, 0.4, 0.7, 0.4];
    return pattern[index % pattern.length];
  }
}

// ═══════════════ دايرة القضية ═══════════════
class _CaseNode extends StatelessWidget {
  final int caseId;
  final String title;
  final int stars;
  final bool isCurrent;
  final VoidCallback onTap;

  const _CaseNode({
    required this.caseId,
    required this.title,
    required this.stars,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF141110),
              border: Border.all(
                color: isCurrent ? P.rare : P.mid,
                width: isCurrent ? 4 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isCurrent ? P.rare : P.mid).withOpacity(
                    isCurrent ? 0.7 : 0.3,
                  ),
                  blurRadius: isCurrent ? 30 : 12,
                  spreadRadius: isCurrent ? 2 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CASE',
                  style: TextStyle(
                    color: P.dim,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '$caseId',
                  style: TextStyle(
                    color: isCurrent ? P.rare : P.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 140,
            child: Text(
              title,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCurrent ? P.white : P.dim,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final filled = i < stars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: filled ? P.gold : P.dim,
                  size: 14,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}