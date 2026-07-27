import 'package:equatable/equatable.dart';

enum QuizQuestionType { singleChoice, multipleChoice, codeOutput, trueFalse }

class QuizQuestion extends Equatable {
  final String id;
  final QuizQuestionType type;
  final String questionTg;
  final String questionRu;
  final String questionEn;
  final List<String> options;
  final List<int> correctOptionIndexes;
  final String explanationTg;
  final String explanationRu;
  final String explanationEn;

  const QuizQuestion({
    required this.id,
    required this.type,
    required this.questionTg,
    required this.questionRu,
    required this.questionEn,
    required this.options,
    required this.correctOptionIndexes,
    required this.explanationTg,
    required this.explanationRu,
    required this.explanationEn,
  });

  String questionFor(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return questionRu;
      case 'en':
        return questionEn;
      case 'tg':
      default:
        return questionTg;
    }
  }

  String explanationFor(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return explanationRu;
      case 'en':
        return explanationEn;
      case 'tg':
      default:
        return explanationTg;
    }
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      type: QuizQuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuizQuestionType.singleChoice,
      ),
      questionTg: json['questionTg'] as String,
      questionRu: json['questionRu'] as String,
      questionEn: json['questionEn'] as String,
      options: (json['options'] as List).map((e) => e as String).toList(),
      correctOptionIndexes:
          (json['correctOptionIndexes'] as List).map((e) => e as int).toList(),
      explanationTg: json['explanationTg'] as String,
      explanationRu: json['explanationRu'] as String,
      explanationEn: json['explanationEn'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'questionTg': questionTg,
        'questionRu': questionRu,
        'questionEn': questionEn,
        'options': options,
        'correctOptionIndexes': correctOptionIndexes,
        'explanationTg': explanationTg,
        'explanationRu': explanationRu,
        'explanationEn': explanationEn,
      };

  @override
  List<Object?> get props => [
        id,
        type,
        questionTg,
        questionRu,
        questionEn,
        options,
        correctOptionIndexes,
        explanationTg,
        explanationRu,
        explanationEn,
      ];
}

class QuizEntity extends Equatable {
  final String id;
  final String lessonId;
  final List<QuizQuestion> questions;
  final int passThresholdPercent;

  const QuizEntity({
    required this.id,
    required this.lessonId,
    required this.questions,
    this.passThresholdPercent = 70,
  });

  factory QuizEntity.fromJson(Map<String, dynamic> json) {
    return QuizEntity(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      questions: (json['questions'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      passThresholdPercent: json['passThresholdPercent'] as int? ?? 70,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'questions': questions.map((e) => e.toJson()).toList(),
        'passThresholdPercent': passThresholdPercent,
      };

  @override
  List<Object?> get props => [id, lessonId, questions, passThresholdPercent];
}
