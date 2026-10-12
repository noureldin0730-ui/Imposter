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
    HapticFeedback.lightImpact();
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
                          '$_totalStars / ${kTotalCases * 3}',
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
                itemCount: kTotalCases,
                itemBuilder: (context, index) {
                  final caseId = index + 1;
                  final stars = _stars[caseId] ?? 0;
                  final isCurrent = caseId == _currentCase;
                  final offset = _zigzagOffset(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Align(
                      alignment: Alignment(offset, 0),
                      child: _CaseNode(
                        caseId: caseId,
                        stars: stars,
                        isCurrent: isCurrent,
                        onTap: () => _openCase(caseId),
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
  final int stars;
  final bool isCurrent;
  final VoidCallback onTap;

  const _CaseNode({
    required this.caseId,
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
          Container(
            width: 70,
            height: 70,
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
                  blurRadius: isCurrent ? 24 : 8,
                  spreadRadius: isCurrent ? 2 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '$caseId',
              style: TextStyle(
                color: isCurrent ? P.rare : P.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
                  size: 12,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}