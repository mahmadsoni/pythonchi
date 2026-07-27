import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/achievements.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/providers/dashboard_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(progressRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дастовардҳо')),
      body: FutureBuilder<Set<String>>(
        future: repo.getUnlockedAchievementIds(),
        builder: (context, snapshot) {
          final unlocked = snapshot.data ?? <String>{};
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: kAllAchievements.length,
            itemBuilder: (context, i) {
              final a = kAllAchievements[i];
              final isUnlocked = unlocked.contains(a.id);
              return Card(
                color: isUnlocked ? null : AppColors.lightSurfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: isUnlocked
                            ? AppColors.pythonYellow.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.15),
                        child: Icon(
                          a.icon,
                          size: 28,
                          color: isUnlocked ? AppColors.pythonBlue : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        a.titleTg,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isUnlocked ? null : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.descriptionTg,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
