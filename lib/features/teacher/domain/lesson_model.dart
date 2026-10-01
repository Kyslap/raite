class LessonModel {
  final String id;
  final String classId;
  final String className;
  final String title;
  final String content;
  final String estimatedMinutes;
  final List<String> objectives;
  final List<String> quizQuestions;
  final DateTime createdAt;

  const LessonModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.title,
    required this.content,
    required this.estimatedMinutes,
    this.objectives = const [],
    this.quizQuestions = const [],
    required this.createdAt,
  });

  LessonModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? title,
    String? content,
    String? estimatedMinutes,
    List<String>? objectives,
    List<String>? quizQuestions,
    DateTime? createdAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      title: title ?? this.title,
      content: content ?? this.content,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      objectives: objectives ?? this.objectives,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
