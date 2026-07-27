import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/lesson_entity.dart';
import '../../../dashboard/providers/dashboard_providers.dart';
import '../../../playground/services/python_mock_interpreter.dart';

final _lessonProvider = FutureProvider.family<LessonEntity?, String>((ref, lessonId) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getLesson(lessonId);
});

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late TextEditingController _codeController;
  String _output = '';
  bool _challengeSolved = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _runChallenge(LessonChallenge challenge) {
    final result = PythonMockInterpreter.run(_codeController.text);
    setState(() {
      _output = result;
      _challengeSolved = result.contains(challenge.expectedOutputContains) &&
          challenge.expectedOutputContains.isNotEmpty;
    });
  }

  Future<void> _completeLesson(LessonEntity lesson) async {
    final repo = ref.read(progressRepositoryProvider);
    final result = await repo.completeLesson(lessonId: lesson.id, xpReward: lesson.xpReward);
    ref.invalidate(completedLessonIdsProvider);
    ref.invalidate(nextLessonProvider);

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.celebration_rounded, color: AppColors.pythonYellow, size: 40),
        title: Text(result.leveledUp ? 'Дараҷаи нав! Дараҷа ${result.newLevel} 🎉' : 'Дарс анҷом ёфт!'),
        content: Text('Шумо +${lesson.xpReward} XP гирифтед. Ҳоло ${result.newTotalXp} XP доред.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ХУБ'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lessonAsync = ref.watch(_lessonProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Дарс')),
      body: lessonAsync.when(
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Дарс ёфт нашуд'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(lesson.titleTg, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 14, color: AppColors.lightOnSurfaceMuted),
                  Text(' ${lesson.estimatedMinutes} дақ  ·  ', style: TextStyle(color: AppColors.lightOnSurfaceMuted)),
                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.pythonYellow),
                  Text(' +${lesson.xpReward} XP', style: TextStyle(color: AppColors.lightOnSurfaceMuted)),
                ],
              ),
              const SizedBox(height: 20),
              ...lesson.content.map(_buildBlock),
              if (lesson.challenges.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Машқи амалӣ', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...lesson.challenges.map((c) => _buildChallenge(c)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeLesson(lesson),
                  child: const Text('Дарс анҷом ёфт'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Хатогӣ: $e')),
      ),
    );
  }

  Widget _buildBlock(LessonContentBlock block) {
    switch (block.type) {
      case LessonContentBlockType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(block.content, style: const TextStyle(fontSize: 15, height: 1.6)),
        );
      case LessonContentBlockType.code:
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF282C34),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: HighlightView(
            block.content,
            language: block.language ?? 'python',
            theme: atomOneDarkTheme,
            padding: EdgeInsets.zero,
            textStyle: GoogleFonts.jetBrainsMono(fontSize: 13.5),
          ),
        );
      case LessonContentBlockType.tip:
        return _calloutBox(block.content, Icons.lightbulb_rounded, AppColors.info);
      case LessonContentBlockType.warning:
        return _calloutBox(block.content, Icons.warning_rounded, AppColors.warning);
      case LessonContentBlockType.image:
        return const SizedBox.shrink(); // reserved for future asset-based diagrams
    }
  }

  Widget _calloutBox(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildChallenge(LessonChallenge challenge) {
    if (_codeController.text.isEmpty) {
      _codeController.text = challenge.starterCode;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF282C34),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _codeController,
                maxLines: 6,
                style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13.5),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _runChallenge(challenge),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Санҷидан'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Ишора'),
                      content: Text(challenge.hint),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ХУБ')),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.help_outline_rounded, size: 18),
                  label: const Text('Ишора'),
                ),
              ],
            ),
            if (_output.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_challengeSolved ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _output,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: _challengeSolved ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              if (_challengeSolved)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Дуруст аст! 🎉', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
