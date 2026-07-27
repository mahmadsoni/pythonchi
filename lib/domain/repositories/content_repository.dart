import '../entities/lesson_entity.dart';
import '../entities/quiz_entity.dart';

/// Abstraction over where course content comes from (bundled assets today,
/// potentially a remote CMS/API in the future — screens never need to know).
abstract class ContentRepository {
  Future<List<ModuleEntity>> getModules();
  Future<ModuleEntity?> getModule(String moduleId);
  Future<LessonEntity?> getLesson(String lessonId);
  Future<List<LessonEntity>> getLessonsForModule(String moduleId);
  Future<QuizEntity?> getQuizForLesson(String lessonId);
}
