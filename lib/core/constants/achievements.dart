import 'package:flutter/material.dart';

class AchievementDef {
  final String id;
  final String titleTg;
  final String titleRu;
  final String titleEn;
  final String descriptionTg;
  final IconData icon;

  const AchievementDef({
    required this.id,
    required this.titleTg,
    required this.titleRu,
    required this.titleEn,
    required this.descriptionTg,
    required this.icon,
  });

  String titleFor(String lang) {
    switch (lang) {
      case 'ru':
        return titleRu;
      case 'en':
        return titleEn;
      default:
        return titleTg;
    }
  }
}

/// All achievements available in the app. Unlock conditions are evaluated
/// in ProgressRepository / providers as events happen (lesson complete,
/// streak update, quiz pass, etc).
const List<AchievementDef> kAllAchievements = [
  AchievementDef(
    id: 'first_lesson',
    titleTg: 'Қадами аввал',
    titleRu: 'Первый шаг',
    titleEn: 'First Step',
    descriptionTg: 'Аввалин дарси худро анҷом додед',
    icon: Icons.flag_rounded,
  ),
  AchievementDef(
    id: 'streak_3',
    titleTg: '3 рӯзи паиҳам',
    titleRu: '3 дня подряд',
    titleEn: '3-Day Streak',
    descriptionTg: '3 рӯз паиҳам омӯзиш кардед',
    icon: Icons.local_fire_department_rounded,
  ),
  AchievementDef(
    id: 'streak_7',
    titleTg: 'Ҳафтаи оташин',
    titleRu: 'Огненная неделя',
    titleEn: 'Fire Week',
    descriptionTg: '7 рӯз паиҳам омӯзиш кардед',
    icon: Icons.whatshot_rounded,
  ),
  AchievementDef(
    id: 'module_complete_basics',
    titleTg: 'Устоди асосҳо',
    titleRu: 'Мастер основ',
    titleEn: 'Basics Master',
    descriptionTg: 'Модули "Асосҳои Python"-ро анҷом додед',
    icon: Icons.school_rounded,
  ),
  AchievementDef(
    id: 'quiz_perfect',
    titleTg: 'Натиҷаи беҳамто',
    titleRu: 'Идеальный результат',
    titleEn: 'Perfect Score',
    descriptionTg: 'Санҷишеро бо 100% гузаштед',
    icon: Icons.emoji_events_rounded,
  ),
  AchievementDef(
    id: 'playground_10',
    titleTg: 'Озмоишгар',
    titleRu: 'Экспериментатор',
    titleEn: 'Experimenter',
    descriptionTg: '10 маротиба дар Playground код иҷро кардед',
    icon: Icons.science_rounded,
  ),
];
