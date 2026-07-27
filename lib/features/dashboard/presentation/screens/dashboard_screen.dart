import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/progress_repository.dart';
import '../../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: update streak the moment the dashboard is shown.
    Future.microtask(() => ref.read(progressRepositoryProvider).registerDailyActivity());
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(userProgressStreamProvider);
    final nextLessonAsync = ref.watch(nextLessonProvider);
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: progressAsync.when(
          data: (p) => Text('Салом, ${p.displayName.split(' ').first}! 👋'),
          loading: () => const Text('Салом! 👋'),
          error: (_, __) => const Text('Салом! 👋'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nextLessonProvider);
          ref.invalidate(modulesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            progressAsync.when(
              data: (p) => _StatsRow(
                xp: p.totalXp,
                level: p.level,
                streak: p.currentStreak,
              ),
              loading: () => const SizedBox(height: 96),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text('Омӯзишро идома диҳед', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            nextLessonAsync.when(
              data: (lesson) {
                if (lesson == null) {
                  return _AllDoneCard();
                }
                return _ContinueLearningCard(
                  title: lesson.titleTg,
                  xp: lesson.xpReward,
                  minutes: lesson.estimatedMinutes,
                  onTap: () => context.push('/lesson/${lesson.id}'),
                );
              },
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text('Курсҳо', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            modulesAsync.when(
              data: (modules) => Column(
                children: modules
                    .map((m) => _ModuleCard(
                          title: m.titleTg,
                          lessonCount: m.lessonIds.length,
                          icon: _iconFor(m.iconName),
                          onTap: () => context.push('/lessons/${m.id}'),
                        ))
                    .toList(),
              ),
              loading: () => const _LoadingCard(),
              error: (e, __) => Text('Хатогӣ: $e'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'code':
        return Icons.code_rounded;
      case 'data_array':
        return Icons.data_array_rounded;
      case 'widgets':
        return Icons.widgets_rounded;
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      default:
        return Icons.book_rounded;
    }
  }
}

class _StatsRow extends StatelessWidget {
  final int xp;
  final int level;
  final int streak;
  const _StatsRow({required this.xp, required this.level, required this.streak});

  @override
  Widget build(BuildContext context) {
    final nextLevelXp = xpRequiredForLevel(level + 1);
    final currentLevelXp = xpRequiredForLevel(level);
    final progress = ((xp - currentLevelXp) / (nextLevelXp - currentLevelXp)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatChip(icon: Icons.bolt_rounded, label: '$xp XP', color: Colors.white),
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                label: '$streak рӯз',
                color: AppColors.pythonYellow,
              ),
              _StatChip(icon: Icons.military_tech_rounded, label: 'Дараҷа $level', color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(AppColors.pythonYellow),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${xp - currentLevelXp} / ${nextLevelXp - currentLevelXp} XP то дараҷаи навбатӣ',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final String title;
  final int xp;
  final int minutes;
  final VoidCallback onTap;

  const _ContinueLearningCard({
    required this.title,
    required this.xp,
    required this.minutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.indigoLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.indigoLight, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('$minutes дақ · +$xp XP',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.lightOnSurfaceMuted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: AppColors.pythonYellow, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Офарин! Шумо ҳамаи дарсҳои дастрасро анҷом додед 🎉'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final int lessonCount;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.lessonCount,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.pythonYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.pythonBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      Text('$lessonCount дарс',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.lightOnSurfaceMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
