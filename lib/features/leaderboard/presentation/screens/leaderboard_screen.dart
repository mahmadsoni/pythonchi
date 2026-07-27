import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';

/// NOTE ON ARCHITECTURE:
/// True cross-user leaderboards require a backend (to aggregate XP across
/// installs). Since this app is currently offline-first / local-only, this
/// screen shows the user's own standing plus illustrative demo entries so
/// the full UI/UX is in place. Wiring this to a real backend (e.g. Firebase
/// or a custom API) later only requires swapping the data source below —
/// the widget tree does not need to change.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressStreamProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Рейтинги беҳтаринҳо'),
          bottom: const TabBar(tabs: [Tab(text: 'Ҳафтаина'), Tab(text: 'Умумӣ')]),
        ),
        body: progressAsync.when(
          data: (progress) {
            final demoEntries = <_LeaderEntry>[
              const _LeaderEntry('Азиз Раҳимов', 2450, 1),
              const _LeaderEntry('Мадина Каримова', 2100, 2),
              _LeaderEntry(progress.displayName, progress.totalXp, 3, isMe: true),
              const _LeaderEntry('Ҷасур Назаров', 890, 4),
              const _LeaderEntry('Фарҳод Олимов', 620, 5),
            ]..sort((a, b) => b.xp.compareTo(a.xp));

            final ranked = [
              for (int i = 0; i < demoEntries.length; i++)
                _LeaderEntry(demoEntries[i].name, demoEntries[i].xp, i + 1, isMe: demoEntries[i].isMe),
            ];

            final list = ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ranked.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _LeaderTile(entry: ranked[i]),
            );

            return TabBarView(children: [list, list]);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Хатогӣ: $e')),
        ),
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final int xp;
  final int rank;
  final bool isMe;
  const _LeaderEntry(this.name, this.xp, this.rank, {this.isMe = false});
}

class _LeaderTile extends StatelessWidget {
  final _LeaderEntry entry;
  const _LeaderTile({required this.entry});

  Color get _medalColor {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.lightOnSurfaceMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: entry.isMe ? AppColors.indigoLight.withOpacity(0.08) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: entry.rank <= 3
                  ? Icon(Icons.emoji_events_rounded, color: _medalColor)
                  : Text('${entry.rank}', textAlign: TextAlign.center, style: TextStyle(color: _medalColor, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: AppColors.pythonBlue.withOpacity(0.15),
              child: Text(
                entry.name.isNotEmpty ? entry.name.substring(0, 1) : '?',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.isMe ? '${entry.name} (Шумо)' : entry.name,
                style: TextStyle(fontWeight: entry.isMe ? FontWeight.w700 : FontWeight.w500),
              ),
            ),
            Text('${entry.xp} XP', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.pythonYellow)),
          ],
        ),
      ),
    );
  }
}
