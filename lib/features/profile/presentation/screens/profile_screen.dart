import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/local/app_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Тағйири ном'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Бекор кардан')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Нигоҳ доштан'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final db = ref.read(appDatabaseProvider);
      await (db.update(db.userProgressTable)).write(
        UserProgressTableCompanion(displayName: drift.Value(result)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профили ман')),
      body: progressAsync.when(
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.indigoLight.withOpacity(0.15),
                    child: const Icon(Icons.person_rounded, size: 48, color: AppColors.indigoLight),
                  ),
                  const SizedBox(height: 12),
                  Text(p.displayName, style: Theme.of(context).textTheme.headlineSmall),
                  TextButton(
                    onPressed: () => _editName(context, ref, p.displayName),
                    child: const Text('Тағйири ном'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'XP', value: '${p.totalXp}', icon: Icons.bolt_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Дараҷа', value: '${p.level}', icon: Icons.military_tech_rounded)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Streak', value: '${p.currentStreak}', icon: Icons.local_fire_department_rounded)),
              ],
            ),
            const SizedBox(height: 20),
            _MenuTile(
              icon: Icons.emoji_events_outlined,
              label: 'Дастовардҳо',
              onTap: () => context.push('/achievements'),
            ),
            _MenuTile(
              icon: Icons.workspace_premium_outlined,
              label: 'Сертификатҳо',
              onTap: () => context.push('/certificate/python_basics'),
            ),
            _MenuTile(
              icon: Icons.smart_toy_outlined,
              label: 'Ёвари AI',
              onTap: () => context.push('/ai-assistant'),
            ),
            _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Танзимот',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) => Center(
                child: Text(
                  snap.hasData ? 'Pythonchi v${snap.data!.version} (${snap.data!.buildNumber})' : 'Pythonchi',
                  style: TextStyle(color: AppColors.lightOnSurfaceMuted, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Хатогӣ: $e')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.indigoLight),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.lightOnSurfaceMuted)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
