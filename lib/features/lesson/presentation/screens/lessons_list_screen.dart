import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../../../domain/entities/lesson_entity.dart';

class LessonsListScreen extends ConsumerWidget {
  final String moduleId;
  const LessonsListScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsForModuleProvider(moduleId));
    final completedAsync = ref.watch(completedLessonIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дарсҳо')),
      body: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Дарсҳои ин модул ба зудӣ илова карда мешаванд 🚀',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final completed = completedAsync.value ?? <String>{};
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final lesson = lessons[i];
              final isDone = completed.contains(lesson.id);
              final isLocked = i > 0 &&
                  !completed.contains(lessons[i - 1].id) &&
                  lesson.prerequisiteLessonIds.isEmpty == false;

              return _LessonTile(
                index: i + 1,
                lesson: lesson,
                isDone: isDone,
                isLocked: false, // free navigation; prerequisites are advisory only
                onTap: () => context.push('/lesson/${lesson.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Хатогӣ: $e')),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final int index;
  final LessonEntity lesson;
  final bool isDone;
  final bool isLocked;
  final VoidCallback onTap;

  const _LessonTile({
    required this.index,
    required this.lesson,
    required this.isDone,
    required this.isLocked,
    required this.onTap,
  });

  Color get _difficultyColor {
    switch (lesson.difficulty) {
      case LessonDifficulty.beginner:
        return AppColors.difficultyBeginner;
      case LessonDifficulty.intermediate:
        return AppColors.difficultyIntermediate;
      case LessonDifficulty.advanced:
        return AppColors.difficultyAdvanced;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDone
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.indigoLight.withOpacity(0.1),
                child: isDone
                    ? const Icon(Icons.check_rounded, color: AppColors.success)
                    : Text('$index', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lesson.titleTg, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _difficultyColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lesson.difficulty.name,
                            style: TextStyle(color: _difficultyColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.bolt_rounded, size: 14, color: AppColors.lightOnSurfaceMuted),
                        Text(' +${lesson.xpReward} XP',
                            style: TextStyle(color: AppColors.lightOnSurfaceMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
