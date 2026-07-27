import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Tracks the currently signed-in local user's overall progress.
class UserProgressTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withDefault(const Constant('Python Learner'))();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActivityDate => dateTime().nullable()();
  TextColumn get languageCode => text().withDefault(const Constant('tg'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Records completion of an individual lesson.
class LessonProgressTable extends Table {
  TextColumn get lessonId => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {lessonId};
}

/// Records quiz attempt results per lesson.
class QuizResultTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get quizId => text()();
  TextColumn get lessonId => text()();
  IntColumn get scorePercent => integer()();
  BoolColumn get passed => boolean()();
  DateTimeColumn get attemptedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Unlocked achievements/badges.
class AchievementTable extends Table {
  TextColumn get achievementId => text()();
  DateTimeColumn get unlockedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {achievementId};
}

/// Saved playground code snippets.
class PlaygroundSnippetTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get code => text()();
  DateTimeColumn get savedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Issued certificates for completed courses.
class CertificateTable extends Table {
  TextColumn get courseId => text()();
  TextColumn get userDisplayName => text()();
  DateTimeColumn get issuedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {courseId};
}

@DriftDatabase(tables: [
  UserProgressTable,
  LessonProgressTable,
  QuizResultTable,
  AchievementTable,
  PlaygroundSnippetTable,
  CertificateTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Bump this whenever the schema changes and add a migration step below.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed a default single local-user progress row.
          await into(userProgressTable).insert(
            UserProgressTableCompanion.insert(),
          );
        },
        onUpgrade: (m, from, to) async {
          // Future schema migrations are added here, e.g.:
          // if (from < 2) { await m.addColumn(...); }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pythonchi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
