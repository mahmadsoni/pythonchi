import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// XP required to reach a given level. Uses a smooth curve so early levels
/// come fast (motivating new learners) and later levels take longer.
int xpRequiredForLevel(int level) => 50 * level * level;

int levelForTotalXp(int totalXp) {
  int level = 1;
  while (xpRequiredForLevel(level + 1) <= totalXp) {
    level++;
  }
  return level;
}

/// Central place for all gamification + progress side-effects, so screens
/// stay dumb and testable.
class ProgressRepository {
  final AppDatabase db;
  ProgressRepository(this.db);

  Future<UserProgressTableData> _currentProgress() {
    return db.select(db.userProgressTable).getSingle();
  }

  /// Call whenever the user opens the app for the day — updates streaks.
  Future<void> registerDailyActivity() async {
    final progress = await _currentProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (progress.lastActivityDate == null) {
      await _writeStreak(currentStreak: 1, longestStreak: 1, lastActivity: today);
      return;
    }

    final last = progress.lastActivityDate!;
    final lastDay = DateTime(last.year, last.month, last.day);
    final dayDiff = today.difference(lastDay).inDays;

    if (dayDiff == 0) {
      return; // already logged today
    } else if (dayDiff == 1) {
      final newStreak = progress.currentStreak + 1;
      await _writeStreak(
        currentStreak: newStreak,
        longestStreak: newStreak > progress.longestStreak ? newStreak : progress.longestStreak,
        lastActivity: today,
      );
    } else {
      await _writeStreak(currentStreak: 1, longestStreak: progress.longestStreak, lastActivity: today);
    }
  }

  Future<void> _writeStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastActivity,
  }) async {
    await (db.update(db.userProgressTable)).write(
      UserProgressTableCompanion(
        currentStreak: Value(currentStreak),
        longestStreak: Value(longestStreak),
        lastActivityDate: Value(lastActivity),
      ),
    );
  }

  /// Marks a lesson complete, awards XP, and recalculates level.
  /// Returns the new total XP and whether this was a level-up.
  Future<({int newTotalXp, bool leveledUp, int newLevel})> completeLesson({
    required String lessonId,
    required int xpReward,
  }) async {
    final existing = await (db.select(db.lessonProgressTable)
          ..where((t) => t.lessonId.equals(lessonId)))
        .getSingleOrNull();

    if (existing != null && existing.isCompleted) {
      // Already completed — no double XP, but count the re-attempt.
      await (db.update(db.lessonProgressTable)..where((t) => t.lessonId.equals(lessonId)))
          .write(LessonProgressTableCompanion(attemptCount: Value(existing.attemptCount + 1)));
      final progress = await _currentProgress();
      return (newTotalXp: progress.totalXp, leveledUp: false, newLevel: progress.level);
    }

    await db.into(db.lessonProgressTable).insertOnConflictUpdate(
          LessonProgressTableCompanion.insert(
            lessonId: lessonId,
            isCompleted: const Value(true),
            xpEarned: Value(xpReward),
            completedAt: Value(DateTime.now()),
            attemptCount: Value((existing?.attemptCount ?? 0) + 1),
          ),
        );

    final progress = await _currentProgress();
    final newTotalXp = progress.totalXp + xpReward;
    final oldLevel = progress.level;
    final newLevel = levelForTotalXp(newTotalXp);

    await (db.update(db.userProgressTable)).write(
      UserProgressTableCompanion(
        totalXp: Value(newTotalXp),
        level: Value(newLevel),
      ),
    );

    return (newTotalXp: newTotalXp, leveledUp: newLevel > oldLevel, newLevel: newLevel);
  }

  Future<void> recordQuizResult({
    required String quizId,
    required String lessonId,
    required int scorePercent,
    required bool passed,
  }) async {
    await db.into(db.quizResultTable).insert(
          QuizResultTableCompanion.insert(
            quizId: quizId,
            lessonId: lessonId,
            scorePercent: scorePercent,
            passed: passed,
          ),
        );
  }

  Future<void> unlockAchievement(String achievementId) async {
    final exists = await (db.select(db.achievementTable)
          ..where((t) => t.achievementId.equals(achievementId)))
        .getSingleOrNull();
    if (exists != null) return;
    await db.into(db.achievementTable).insert(
          AchievementTableCompanion.insert(achievementId: achievementId),
        );
  }

  Future<Set<String>> getUnlockedAchievementIds() async {
    final rows = await db.select(db.achievementTable).get();
    return rows.map((r) => r.achievementId).toSet();
  }

  Future<Set<String>> getCompletedLessonIds() async {
    final rows = await (db.select(db.lessonProgressTable)
          ..where((t) => t.isCompleted.equals(true)))
        .get();
    return rows.map((r) => r.lessonId).toSet();
  }
}
