import 'package:equatable/equatable.dart';

enum LessonDifficulty { beginner, intermediate, advanced }

enum LessonContentBlockType { text, code, image, tip, warning }

/// A single content block inside a lesson (rendered in order).
class LessonContentBlock extends Equatable {
  final LessonContentBlockType type;
  final String content;
  final String? language; // for code blocks, e.g. "python"

  const LessonContentBlock({
    required this.type,
    required this.content,
    this.language,
  });

  factory LessonContentBlock.fromJson(Map<String, dynamic> json) {
    return LessonContentBlock(
      type: LessonContentBlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LessonContentBlockType.text,
      ),
      content: json['content'] as String,
      language: json['language'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'content': content,
        if (language != null) 'language': language,
      };

  @override
  List<Object?> get props => [type, content, language];
}

/// A practice challenge attached to a lesson (fill-in-the-blank / code task).
class LessonChallenge extends Equatable {
  final String id;
  final String prompt;
  final String starterCode;
  final String expectedOutputContains;
  final String hint;
  final String solution;

  const LessonChallenge({
    required this.id,
    required this.prompt,
    required this.starterCode,
    required this.expectedOutputContains,
    required this.hint,
    required this.solution,
  });

  factory LessonChallenge.fromJson(Map<String, dynamic> json) {
    return LessonChallenge(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      starterCode: json['starterCode'] as String,
      expectedOutputContains: json['expectedOutputContains'] as String,
      hint: json['hint'] as String,
      solution: json['solution'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'starterCode': starterCode,
        'expectedOutputContains': expectedOutputContains,
        'hint': hint,
        'solution': solution,
      };

  @override
  List<Object?> get props => [id, prompt, starterCode, expectedOutputContains, hint, solution];
}

class LessonEntity extends Equatable {
  final String id;
  final String moduleId;
  final int orderIndex;
  final String titleTg;
  final String titleRu;
  final String titleEn;
  final LessonDifficulty difficulty;
  final int xpReward;
  final int estimatedMinutes;
  final List<LessonContentBlock> content;
  final List<LessonChallenge> challenges;
  final List<String> prerequisiteLessonIds;

  const LessonEntity({
    required this.id,
    required this.moduleId,
    required this.orderIndex,
    required this.titleTg,
    required this.titleRu,
    required this.titleEn,
    required this.difficulty,
    required this.xpReward,
    required this.estimatedMinutes,
    required this.content,
    required this.challenges,
    this.prerequisiteLessonIds = const [],
  });

  String titleFor(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return titleRu;
      case 'en':
        return titleEn;
      case 'tg':
      default:
        return titleTg;
    }
  }

  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      orderIndex: json['orderIndex'] as int,
      titleTg: json['titleTg'] as String,
      titleRu: json['titleRu'] as String,
      titleEn: json['titleEn'] as String,
      difficulty: LessonDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => LessonDifficulty.beginner,
      ),
      xpReward: json['xpReward'] as int,
      estimatedMinutes: json['estimatedMinutes'] as int,
      content: (json['content'] as List)
          .map((e) => LessonContentBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      challenges: (json['challenges'] as List)
          .map((e) => LessonChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      prerequisiteLessonIds: (json['prerequisiteLessonIds'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'orderIndex': orderIndex,
        'titleTg': titleTg,
        'titleRu': titleRu,
        'titleEn': titleEn,
        'difficulty': difficulty.name,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
        'content': content.map((e) => e.toJson()).toList(),
        'challenges': challenges.map((e) => e.toJson()).toList(),
        'prerequisiteLessonIds': prerequisiteLessonIds,
      };

  @override
  List<Object?> get props => [
        id,
        moduleId,
        orderIndex,
        titleTg,
        titleRu,
        titleEn,
        difficulty,
        xpReward,
        estimatedMinutes,
        content,
        challenges,
        prerequisiteLessonIds,
      ];
}

class ModuleEntity extends Equatable {
  final String id;
  final int orderIndex;
  final String titleTg;
  final String titleRu;
  final String titleEn;
  final String iconName;
  final List<String> lessonIds;

  const ModuleEntity({
    required this.id,
    required this.orderIndex,
    required this.titleTg,
    required this.titleRu,
    required this.titleEn,
    required this.iconName,
    required this.lessonIds,
  });

  String titleFor(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return titleRu;
      case 'en':
        return titleEn;
      case 'tg':
      default:
        return titleTg;
    }
  }

  factory ModuleEntity.fromJson(Map<String, dynamic> json) {
    return ModuleEntity(
      id: json['id'] as String,
      orderIndex: json['orderIndex'] as int,
      titleTg: json['titleTg'] as String,
      titleRu: json['titleRu'] as String,
      titleEn: json['titleEn'] as String,
      iconName: json['iconName'] as String,
      lessonIds: (json['lessonIds'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderIndex': orderIndex,
        'titleTg': titleTg,
        'titleRu': titleRu,
        'titleEn': titleEn,
        'iconName': iconName,
        'lessonIds': lessonIds,
      };

  @override
  List<Object?> get props => [id, orderIndex, titleTg, titleRu, titleEn, iconName, lessonIds];
}
