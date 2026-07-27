import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/core_providers.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/entities/lesson_entity.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProgressRepository(db);
});

final modulesProvider = FutureProvider<List<ModuleEntity>>((ref) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getModules();
});

final lessonsForModuleProvider =
    FutureProvider.family<List<LessonEntity>, String>((ref, moduleId) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getLessonsForModule(moduleId);
});

final completedLessonIdsProvider = FutureProvider<Set<String>>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getCompletedLessonIds();
});

/// Finds the next uncompleted lesson across all modules, in order —
/// used for the dashboard's "Continue Learning" card.
final nextLessonProvider = FutureProvider<LessonEntity?>((ref) async {
  final modules = await ref.watch(modulesProvider.future);
  final completed = await ref.watch(completedLessonIdsProvider.future);
  final contentRepo = ref.watch(contentRepositoryProvider);

  for (final module in modules) {
    final lessons = await contentRepo.getLessonsForModule(module.id);
    for (final lesson in lessons) {
      if (!completed.contains(lesson.id)) {
        return lesson;
      }
    }
  }
  return null;
});
