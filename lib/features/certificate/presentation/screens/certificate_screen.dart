import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/providers/dashboard_providers.dart';

class CertificateScreen extends ConsumerWidget {
  final String courseId;
  const CertificateScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressStreamProvider);
    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Сертификати шумо')),
      body: progressAsync.when(
        data: (progress) => modulesAsync.when(
          data: (modules) {
            final module = modules.where((m) => m.id == courseId).firstOrNull;
            final courseTitle = module?.titleTg ?? 'Python';
            final today = DateFormat('dd.MM.yyyy').format(DateTime.now());

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.brandGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.pythonYellow, width: 3),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: AppColors.pythonYellow, size: 56),
                          const SizedBox(height: 16),
                          const Text(
                            'СЕРТИФИКАТИ АНҶОМДИҲӢ',
                            style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            progress.displayName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'бо муваффақият курси',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$courseTitle"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.pythonYellow, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'дар Pythonchi-ро анҷом дод',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                          ),
                          const SizedBox(height: 24),
                          Text(today, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Share.share(
                            '${progress.displayName} курси "$courseTitle"-ро дар Pythonchi бо муваффақият анҷом дод! 🎉🐍',
                          ),
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Мубодила'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Хатогӣ: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Хатогӣ: $e')),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
