import 'package:shared_preferences/shared_preferences.dart';

class SaveManager {
  // ═══════════════ نجوم كل قضية ═══════════════
  static Future<Map<int, int>> getStars() async {
    final p = await SharedPreferences.getInstance();
    final map = <int, int>{};
    for (int i = 1; i <= 300; i++) {
      final s = p.getInt('stars_$i');
      if (s != null) map[i] = s;
    }
    return map;
  }

  static Future<int> getStarsFor(int caseId) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('stars_$caseId') ?? 0;
  }

  static Future<void> setStars(int caseId, int stars) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt('stars_$caseId') ?? 0;
    // سجّل أعلى نجمة بس
    if (stars > current) {
      await p.setInt('stars_$caseId', stars);
    }
  }

  // ═══════════════ فتح المراحل ═══════════════
  static Future<bool> isUnlocked(int caseId) async {
    if (caseId == 1) return true;
    final p = await SharedPreferences.getInstance();
    return p.getBool('unlocked_$caseId') ?? false;
  }

  static Future<void> unlock(int caseId) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('unlocked_$caseId', true);
  }

  // ═══════════════ المرحلة الحالية ═══════════════
  static Future<int> getCurrentCase() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('current_case') ?? 1;
  }

  static Future<void> setCurrentCase(int caseId) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('current_case', caseId);
  }

  // ═══════════════ إجمالي النجوم ═══════════════
  static Future<int> getTotalStars() async {
    final stars = await getStars();
    return stars.values.fold<int>(0, (a, b) => a + b);
  }

  // ═══════════════ إعادة التعيين ═══════════════
  static Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}