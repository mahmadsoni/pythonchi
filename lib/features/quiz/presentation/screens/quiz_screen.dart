import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/quiz_entity.dart';
import '../../../dashboard/providers/dashboard_providers.dart';

final _quizProvider = FutureProvider.family<QuizEntity?, String>((ref, lessonId) async {
  final repo = ref.watch(contentRepositoryProvider);
  return repo.getQuizForLesson(lessonId);
});

class QuizScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const QuizScreen({super.key, required this.lessonId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final Map<String, int> _selectedAnswers = {};
  bool _submitted = false;

  int _scorePercent(QuizEntity quiz) {
    if (quiz.questions.isEmpty) return 0;
    int correct = 0;
    for (final q in quiz.questions) {
      final selected = _selectedAnswers[q.id];
      if (selected != null && q.correctOptionIndexes.contains(selected)) correct++;
    }
    return ((correct / quiz.questions.length) * 100).round();
  }

  Future<void> _submit(QuizEntity quiz) async {
    final score = _scorePercent(quiz);
    final passed = score >= quiz.passThresholdPercent;
    setState(() => _submitted = true);

    final repo = ref.read(progressRepositoryProvider);
    await repo.recordQuizResult(
      quizId: quiz.id,
      lessonId: quiz.lessonId,
      scorePercent: score,
      passed: passed,
    );
    if (score == 100) {
      await repo.unlockAchievement('quiz_perfect');
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(_quizProvider(widget.lessonId));

    return Scaffold(
      appBar: AppBar(title: const Text('Санҷиш')),
      body: quizAsync.when(
        data: (quiz) {
          if (quiz == null) {
            return const Center(child: Text('Барои ин дарс санҷиш нест'));
          }
          if (_submitted) {
            final score = _scorePercent(quiz);
            final passed = score >= quiz.passThresholdPercent;
            return _ResultView(
              score: score,
              passed: passed,
              onRetry: () => setState(() {
                _submitted = false;
                _selectedAnswers.clear();
              }),
              onDone: () => context.pop(),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final q in quiz.questions) _QuestionCard(
                question: q,
                selected: _selectedAnswers[q.id],
                onSelect: (i) => setState(() => _selectedAnswers[q.id] = i),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswers.length == quiz.questions.length ? () => _submit(quiz) : null,
                  child: const Text('Фиристодан'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Хатогӣ: $e')),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _QuestionCard({required this.question, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.questionTg, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            for (int i = 0; i < question.options.length; i++)
              RadioListTile<int>(
                value: i,
                groupValue: selected,
                title: Text(question.options[i]),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => onSelect(v!),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final bool passed;
  final VoidCallback onRetry;
  final VoidCallback onDone;

  const _ResultView({
    required this.score,
    required this.passed,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 72,
              color: passed ? AppColors.pythonYellow : AppColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              passed ? 'Шумо гузаштед! 🎉' : 'Бори дигар кӯшиш кунед',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Натиҷаи шумо: $score%', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: passed ? onDone : onRetry,
                child: Text(passed ? 'Хуб' : 'Такрор кардан'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
