import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/generators.dart';

class P {
  static const bg = Color(0xFF0A0807);
  static const dark = Color(0xFF141110);
  static const dim = Color(0xFF6A5A55);
  static const mid = Color(0xFF8B1A1A);
  static const rare = Color(0xFFC1272D);
  static const white = Color(0xFFE8E2DD);
  static const gold = Color(0xFFB8945C);
  static const green = Color(0xFF4A7C59);
}

class AccuseScreen extends StatefulWidget {
  final Case caseData;
  final String accused;
  final bool correct;
  final int stars;

  const AccuseScreen({
    super.key,
    required this.caseData,
    required this.accused,
    required this.correct,
    required this.stars,
  });

  @override
  State<AccuseScreen> createState() => _AccuseScreenState();
}

class _AccuseScreenState extends State<AccuseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    if (widget.correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.correct;
    final accent = c ? P.green : P.rare;

    return Scaffold(
      backgroundColor: P.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _ctrl,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    c ? Icons.check : Icons.close,
                    color: accent,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  c ? 'الحقيقة اتكشفت' : 'غلط',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: accent,
                    fontSize: 28,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: P.dark,
                    border: Border.all(color: accent.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (c) ...[
                        const Text(
                          'القاتل:',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: P.dim,
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.caseData.killer,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ═══ النجوم ═══
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final filled = i < widget.stars;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: filled ? P.gold : P.dim,
                                size: 40,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _starsLabel(widget.stars),
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: P.gold.withOpacity(0.8),
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Divider(color: Color(0xFF1A1A1A)),
                        const SizedBox(height: 16),
                        Text(
                          widget.caseData.solution,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 14,
                            height: 2.0,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'اتهمت: ${widget.accused}',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: P.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'مش هو. رجّع اقرأ الأدلة والشهادات تاني.',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: P.dim,
                            fontSize: 13,
                            height: 1.9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _goBack,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: accent, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      c ? 'تمام' : 'حاول تاني',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: P.white,
                        fontSize: 16,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══ نص النجوم ═══
  String _starsLabel(int stars) {
    if (stars == 3) return 'قرار مثالي — من أول محاولة';
    if (stars == 2) return 'قرار كويس — بعد محاولة فاشلة';
    if (stars == 1) return 'قرار مقبول — بعد محاولتين فاشلتين';
    return '';
  }
}