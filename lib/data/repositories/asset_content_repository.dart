import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/content_repository.dart';

/// Loads course content bundled as JSON assets under assets/lessons/.
///
/// Content is intentionally data-driven (not hardcoded Dart/Flutter widgets)
/// so new modules and lessons can be added by dropping in new JSON files —
/// no code changes or app releases required for content-only updates.
class AssetContentRepository implements ContentRepository {
  List<ModuleEntity>? _modulesCache;
  final Map<String, List<LessonEntity>> _lessonsCache = {};
  final Map<String, QuizEntity> _quizCache = {};

  Future<List<ModuleEntity>> _loadModules() async {
    if (_modulesCache != null) return _modulesCache!;
    final raw = await rootBundle.loadString('assets/lessons/modules.json');
    final list = jsonDecode(raw) as List;
    _modulesCache = list
        .map((e) => ModuleEntity.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return _modulesCache!;
  }

  Future<List<LessonEntity>> _loadLessonsForModule(String moduleId) async {
    if (_lessonsCache.containsKey(moduleId)) return _lessonsCache[moduleId]!;
    try {
      final raw = await rootBundle.loadString('assets/lessons/$moduleId.json');
      final list = jsonDecode(raw) as List;
      final lessons = list
          .map((e) => LessonEntity.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      _lessonsCache[moduleId] = lessons;
      return lessons;
    } catch (_) {
      // Module JSON not yet authored — treat as "coming soon" rather than crash.
      _lessonsCache[moduleId] = const [];
      return const [];
    }
  }

  @override
  Future<List<ModuleEntity>> getModules() => _loadModules();

  @override
  Future<ModuleEntity?> getModule(String moduleId) async {
    final modules = await _loadModules();
    for (final m in modules) {
      if (m.id == moduleId) return m;
    }
    return null;
  }

  @override
  Future<List<LessonEntity>> getLessonsForModule(String moduleId) {
    return _loadLessonsForModule(moduleId);
  }

  @override
  Future<LessonEntity?> getLesson(String lessonId) async {
    final modules = await _loadModules();
    for (final module in modules) {
      final lessons = await _loadLessonsForModule(module.id);
      for (final lesson in lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  @override
  Future<QuizEntity?> getQuizForLesson(String lessonId) async {
    if (_quizCache.containsKey(lessonId)) return _quizCache[lessonId];
    try {
      final raw = await rootBundle.loadString('assets/lessons/quizzes/$lessonId.json');
      final quiz = QuizEntity.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _quizCache[lessonId] = quiz;
      return quiz;
    } catch (_) {
      return null;
    }
  }
}
