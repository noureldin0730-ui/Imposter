import 'dart:math';
import 'pools.dart';

// ═══════════════ الفئات ═══════════════
class Victim {
  final String name;
  final int age;
  final String job;
  final String description;
  const Victim({
    required this.name,
    required this.age,
    required this.job,
    required this.description,
  });
}

class Suspect {
  final String name;
  final int age;
  final String relation;
  final String story;
  final String alibi;
  const Suspect({
    required this.name,
    required this.age,
    required this.relation,
    required this.story,
    required this.alibi,
  });
}

class Evidence {
  final String title;
  final String detail;
  const Evidence({required this.title, required this.detail});
}

class Testimony {
  final String speaker;
  final String text;
  const Testimony({required this.speaker, required this.text});
}

class Case {
  final int id;
  final String title;
  final String location;
  final String time;
  final String crimeScene;
  final Victim victim;
  final List<Suspect> suspects;
  final List<Evidence> evidences;
  final List<Testimony> testimonies;
  final String killer;
  final String solution;
  const Case({
    required this.id,
    required this.title,
    required this.location,
    required this.time,
    required this.crimeScene,
    required this.victim,
    required this.suspects,
    required this.evidences,
    required this.testimonies,
    required this.killer,
    required this.solution,
  });
}

// ═══════════════ الدالة الرئيسية ═══════════════
Case generateCase(int caseId) {
  final rng = Random(caseId * 9973 + 42);

  final template = kTemplates[caseId % kTemplates.length];

  final victimName = _randomName(rng);
  final victimJob = kVictimJobs[rng.nextInt(kVictimJobs.length)];
  final victimDesc =
      kVictimDescriptions[rng.nextInt(kVictimDescriptions.length)];
  final victimAge = 35 + rng.nextInt(40);

  final suspectNames = <String>{};
  while (suspectNames.length < 5) {
    suspectNames.add(_randomName(rng));
  }
  final suspectsList = suspectNames.toList()..shuffle(rng);

  final killerIndex = rng.nextInt(suspectsList.length);
  final killerName = suspectsList[killerIndex];

  // ═══ حجج متشابهة للكل — صعب ═══
  final alibis = [
    'كنت في البيت لوحدي',
    'كنت نايم',
    'مشيت بدري',
    'كنت في الشغل، مفيش حد معايا',
    'كنت في مكان مزدحم ومش مركز',
    'كنت في الطريق',
    'كنت في مكالمة',
    'كنت في سيارة تاكسي',
    'كنت في السوق',
    'كنت بتمشى',
    'كنت في القهوة',
    'كنت في بيت صاحبي',
  ];
  alibis.shuffle(rng);

  final suspects = <Suspect>[];
  for (int i = 0; i < suspectsList.length; i++) {
    final isKiller = i == killerIndex;
    final motive = isKiller
        ? _pickKillerMotive(rng)
        : _pickMotive(rng); // دوافع مختلفة للقاتل
    final relation = _pickRelation(rng);
    final age = 22 + rng.nextInt(40);
    final alibi = alibis[i % alibis.length];

    suspects.add(Suspect(
      name: suspectsList[i],
      age: age,
      relation: relation,
      story: motive,
      alibi: alibi,
    ));
  }

  // ═══════════════════════════════════════
  // ═══ الأدلة — كل مشتبه عنده دليل ضده ═══
  // ═══════════════════════════════════════
  final evidencePool = <Evidence>[];

  // دليل قوي على القاتل
  evidencePool.add(_killerEvidence(killerName, rng));

  // دليل ضعيف على كل مشتبه تاني
  for (int i = 0; i < suspectsList.length; i++) {
    if (i != killerIndex) {
      evidencePool.add(_fakeEvidence(suspectsList[i], rng));
    }
  }

  // 2 أدلة عامة
  final generalPool = List<EvidenceTemplate>.from(kEvidencePool)
    ..shuffle(rng);
  for (final e in generalPool.take(2)) {
    evidencePool.add(Evidence(title: e.title, detail: e.detail));
  }

  evidencePool.shuffle(rng);

  // ═══════════════════════════════════════
  // ═══ الشهادات — كلها بتكذب ═══
  // ═══════════════════════════════════════
  final testimonies = <Testimony>[];

  // شهادة بتشاور على القاتل
  testimonies.add(Testimony(
    speaker: 'شاهد مجهول',
    text: 'شفت $killerName حوالين مكان الجريمة الساعة 11:30.',
  ));

  // شهادات بتشاور على ناس تانية (كذب)
  final fakeSuspects = List<String>.from(suspectsList)
    ..remove(killerName)
    ..shuffle(rng);

  for (int i = 0; i < 2; i++) {
    testimonies.add(Testimony(
      speaker: 'شاهد ${i + 1}',
      text: 'شفت ${fakeSuspects[i]} يخرج من المكان الساعة 11:45.',
    ));
  }

  testimonies.shuffle(rng);

  final crimeScene =
      template.crimeScene.replaceAll('{VICTIM}', victimName);

  final killerSuspect = suspects[killerIndex];
  final solution =
      '$killerName. الدليل الوحيد الحقيقي على $killerName كان '
      '${evidencePool.firstWhere((e) => e.detail.contains(killerName)).title}. '
      'كل الأدلة التانية كانت مضللة.';

  final hour = rng.nextInt(12) + 1;
  final minute = rng.nextInt(60);
  final period = rng.nextBool() ? 'صباحاً' : 'مساءً';
  final time = '$hour:${minute.toString().padLeft(2, '0')} $period';

  return Case(
    id: caseId,
    title: template.title,
    location: template.location,
    time: time,
    crimeScene: crimeScene,
    victim: Victim(
      name: victimName,
      age: victimAge,
      job: victimJob,
      description: victimDesc,
    ),
    suspects: suspects,
    evidences: evidencePool,
    testimonies: testimonies,
    killer: killerName,
    solution: solution,
  );
}

// ═══════════════ أدلة القاتل ═══════════════
Evidence _killerEvidence(String killerName, Random rng) {
  final pool = [
    Evidence(
      title: 'بصمة إصبع مطابقة',
      detail:
          'بصمة إصبع على أداة الجريمة. التحليل مطابق لـ $killerName. '
          'ده الدليل الأكيد.',
    ),
    Evidence(
      title: 'كاميرا مراقبة',
      detail:
          'كاميرا شافت $killerName يدخل مكان الجريمة قبل الجريمة بـ 3 دقايق. '
          'ده الدليل الأكيد.',
    ),
    Evidence(
      title: 'شاهد عيان موثوق',
      detail:
          'شاهد موثوق شاف $killerName يخرج من المكان الساعة 11:45. '
          'ده الدليل الأكيد.',
    ),
    Evidence(
      title: 'تحليل DNA',
      detail:
          'شعرة على أداة الجريمة. التحليل مطابق لـ $killerName. '
          'ده الدليل الأكيد.',
    ),
    Evidence(
      title: 'رسالة مسجلة',
      detail:
          'رسالة على موبايل الضحية من $killerName: "هتيجي النهاردة؟". '
          'ده الدليل الأكيد.',
    ),
    Evidence(
      title: 'أثر أقدام مطابق',
      detail:
          'أثر أقدام بحجم $killerName على شباك الهروب. '
          'ده الدليل الأكيد.',
    ),
  ];
  return pool[rng.nextInt(pool.length)];
}

// ═══════════════ أدلة مضللة ═══════════════
Evidence _fakeEvidence(String suspectName, Random rng) {
  final pool = [
    Evidence(
      title: 'دليل غير مباشر',
      detail:
          '$suspectName كان متضايق من الضحية قبل الجريمة بأسبوع. '
          'مفيش دليل على إنه كان في المكان.',
    ),
    Evidence(
      title: 'خلفية مشبوهة',
      detail:
          '$suspectName كان مديون للضحية. بس كان في مكان تاني وقت الجريمة.',
    ),
    Evidence(
      title: 'خلاف قديم',
      detail:
          'كان بين $suspectName والضحية خلاف على شغل. '
          'بس $suspectName عنده شهود على وجوده في مكان تاني.',
    ),
    Evidence(
      title: 'مكالمة مشبوهة',
      detail:
          'مكالمة بين $suspectName والضحية قبل الجريمة بـ ساعة. '
          'المكالمة كانت عادية.',
    ),
    Evidence(
      title: 'بصمة غامضة',
      detail:
          'بصمة على باب المكان. مش واضحة. ممكن تكون بتاعة $suspectName.',
    ),
    Evidence(
      title: 'شيء شخصي',
      detail:
          'لقوا منديل فيه حاجة شخصية لـ $suspectName. بس مش دليل قاطع.',
    ),
  ];
  return pool[rng.nextInt(pool.length)];
}

// ═══════════════ دوال مساعدة ═══════════════
String _randomName(Random rng) {
  final useMale = rng.nextBool();
  return useMale
      ? kMaleNames[rng.nextInt(kMaleNames.length)]
      : kFemaleNames[rng.nextInt(kFemaleNames.length)];
}

String _pickMotive(Random rng) {
  final pool = [
    'الضحية كان هيفضحه قدام الكل',
    'الضحية كان هيفصله من شغله',
    'الضحية سَرَق منه فلوس',
    'كان بينهم عداوة قديمة',
    'الضحية خطف حبيبته',
    'الضحية اكتشف إنه بيغش',
    'الضحية أخد مشروعه',
    'الضحية هدد يبلغ عنه',
    'الضحية قطع مصدر رزقه',
    'الضحية فضحه في كتاب',
  ];
  return pool[rng.nextInt(pool.length)];
}

String _pickKillerMotive(Random rng) {
  final pool = [
    'الضحية كان هيفضحه قدام الكل',
    'الضحية كان هيفصله من شغله',
    'الضحية سَرَق منه فلوس',
    'كان بينهم عداوة قديمة',
    'الضحية خطف حبيبته',
    'الضحية اكتشف إنه بيغش',
    'الضحية أخد مشروعه',
    'الضحية هدد يبلغ عنه',
    'الضحية قطع مصدر رزقه',
    'الضحية فضحه في كتاب',
  ];
  return pool[rng.nextInt(pool.length)];
}

String _pickRelation(Random rng) {
  final pool = [
    'صديق قديم',
    'جار',
    'شريك في العمل',
    'قريب',
    'موظف',
    'منافس',
    'ابن عم',
    'زميل دراسة',
  ];
  return pool[rng.nextInt(pool.length)];
}