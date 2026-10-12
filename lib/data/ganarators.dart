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

  // 5 مشتبهين
  final suspectNames = <String>{};
  while (suspectNames.length < 5) {
    suspectNames.add(_randomName(rng));
  }
  final suspectsList = suspectNames.toList()..shuffle(rng);

  final killerIndex = rng.nextInt(suspectsList.length);
  final killerName = suspectsList[killerIndex];

  final suspects = <Suspect>[];
  for (int i = 0; i < suspectsList.length; i++) {
    final isKiller = i == killerIndex;
    final motive = _pickMotive(rng);
    final relation = _pickRelation(rng);
    final age = 22 + rng.nextInt(40);
    final alibi = _pickAlibi(rng, isKiller);

    suspects.add(Suspect(
      name: suspectsList[i],
      age: age,
      relation: relation,
      story: motive,
      alibi: alibi,
    ));
  }

  // 4 أدلة
  final evidencePoolCopy = List<EvidenceTemplate>.from(kEvidencePool)
    ..shuffle(rng);
  final evidences = evidencePoolCopy.take(4).map((e) {
    return Evidence(title: e.title, detail: e.detail);
  }).toList();

  // 3 شهادات
  final testimonyPoolCopy = List<TestimonyTemplate>.from(kTestimonyPool)
    ..shuffle(rng);
  final testimonies = testimonyPoolCopy.take(3).map((t) {
    return Testimony(speaker: t.speaker, text: t.text);
  }).toList();

  final crimeScene =
      template.crimeScene.replaceAll('{VICTIM}', victimName);

  final killerSuspect = suspects[killerIndex];
  final solution =
      '$killerName. ${killerSuspect.story}. '
      'الأدلة بتشاور عليه. حكاية "${killerSuspect.alibi}" مكانتش دقيقة.';

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
    evidences: evidences,
    testimonies: testimonies,
    killer: killerName,
    solution: solution,
  );
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

String _pickAlibi(Random rng, bool isKiller) {
  if (isKiller) {
    final falseAlibis = [
      'كنت في البيت لوحدي',
      'كنت في الشغل، مفيش حد معايا',
      'كنت نايم',
      'مشيت بدري، مفيش شهود',
    ];
    return falseAlibis[rng.nextInt(falseAlibes.length)];
  } else {
    final realAlibis = [
      'كنت في البيت، أهلي شهود',
      'كنت في الشغل، زمايلي شهود',
      'كنت في مطعم مع صحابي',
      'كنت في مكالمة مع صاحبي',
    ];
    return realAlibis[rng.nextInt(realAlibis.length)];
  }
}