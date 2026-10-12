import 'generators.dart';
import 'manual_cases.dart';

// ═══════════════ إجمالي القضايا ═══════════════
const int kTotalCases = 100;

// ═══════════════ دالة الحصول على قضية ═══════════════
Case getCase(int id) {
  // المراحل 1-5: قضايا يدوية
  if (id >= 1 && id <= 5) {
    final manual = kManualCases.firstWhere(
      (c) => c.id == id,
      orElse: () => generateCase(id),
    );
    return manual;
  }
  // المراحل 6-100: قضايا مولّدة
  return generateCase(id);
}