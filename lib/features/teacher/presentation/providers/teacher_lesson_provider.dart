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
    return const [
      TeacherClass(
        id: 'class-1',
        title: 'AI & Neural Networks 101',
        department: 'Computer Science',
        code: 'AI-101',
        studentCount: 38,
      ),
      TeacherClass(
        id: 'class-2',
        title: 'Advanced Applied Calculus',
        department: 'Mathematics',
        code: 'MATH-402',
        studentCount: 42,
      ),
      TeacherClass(
        id: 'class-3',
        title: 'Classical & Quantum Dynamics',
        department: 'Physics',
        code: 'PHY-204',
        studentCount: 29,
      ),
    ];
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
    return [
      LessonModel(
        id: 'lesson-1',
        classId: 'class-1',
        className: 'AI & Neural Networks 101',
        title: 'Backpropagation and Gradient Descent',
        content:
            'In this lesson, we break down how gradient descent minimizes loss functions. '
            'We step through computational graphs, partial derivatives with respect to weights, '
            'and practical learning rate scheduling.',
        estimatedMinutes: '45 mins',
        objectives: [
          'Understand forward pass vs backward pass',
          'Calculate partial derivatives with chain rule',
          'Implement batch vs stochastic gradient descent',
        ],
        quizQuestions: [
          'What happens when the learning rate is set excessively high?',
          'How does momentum accelerate convergence in oscillatory gradients?',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      LessonModel(
        id: 'lesson-2',
        classId: 'class-2',
        className: 'Advanced Applied Calculus',
        title: 'Stokes Theorem and Vector Fields',
        content:
            'A rigorous overview of line integrals around closed boundaries versus surface integrals '
            'over orientable manifolds. Applications to electromagnetism and fluid circulation.',
        estimatedMinutes: '60 mins',
        objectives: [
          'Relate surface curl integrals to boundary circulation',
          'Verify Stokes Theorem for piecewise smooth surfaces',
        ],
        quizQuestions: [
          'State the orientation convention for the surface normal in Stokes Theorem.',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
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
