import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/lesson_model.dart';

class TeacherClass {
  final String id;
  final String title;
  final String department;
  final String code;
  final int studentCount;
  final String iconCode;

  const TeacherClass({
    required this.id,
    required this.title,
    required this.department,
    required this.code,
    required this.studentCount,
    this.iconCode = 'school',
  });
}

class TeacherClassNotifier extends Notifier<List<TeacherClass>> {
  @override
  List<TeacherClass> build() {
    return const [];
  }

  TeacherClass addClass({
    required String title,
    required String department,
    String? customCode,
  }) {
    // Generate clean 6-char code if none provided
    final autoCode = customCode?.trim().toUpperCase().isNotEmpty == true
        ? customCode!.trim().toUpperCase()
        : '${department.length >= 3 ? department.substring(0, 3).toUpperCase() : "CLS"}-${(100 + DateTime.now().millisecond % 900)}';

    final newClass = TeacherClass(
      id: 'class-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      department: department,
      code: autoCode,
      studentCount: 0,
    );

    state = [newClass, ...state];
    return newClass;
  }
}

final teacherClassesProvider =
    NotifierProvider<TeacherClassNotifier, List<TeacherClass>>(() {
  return TeacherClassNotifier();
});

class TeacherLessonNotifier extends Notifier<List<LessonModel>> {
  @override
  List<LessonModel> build() {
    return const [];
  }

  void addLesson({
    required String classId,
    required String className,
    required String title,
    required String content,
    required String estimatedMinutes,
    List<String> objectives = const [],
    List<String> quizQuestions = const [],
  }) {
    final newLesson = LessonModel(
      id: 'lesson-${DateTime.now().millisecondsSinceEpoch}',
      classId: classId,
      className: className,
      title: title,
      content: content,
      estimatedMinutes: estimatedMinutes,
      objectives: objectives,
      quizQuestions: quizQuestions,
      createdAt: DateTime.now(),
    );
    state = [newLesson, ...state];
  }
}

final teacherLessonsProvider =
    NotifierProvider<TeacherLessonNotifier, List<LessonModel>>(() {
  return TeacherLessonNotifier();
});
