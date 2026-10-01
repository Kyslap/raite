import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  List<TeacherClass> build() {
    _loadFromSupabase();
    return const [];
  }

  Future<void> _loadFromSupabase() async {
    final client = _client;
    if (client == null) return;
    try {
      final res = await client
          .from('classes')
          .select()
          .order('created_at', ascending: false);

      final loaded = (res as List).map((item) => TeacherClass(
        id: item['id'].toString(),
        title: item['title']?.toString() ?? '',
        department: item['department']?.toString() ?? '',
        code: item['code']?.toString() ?? '',
        studentCount: (item['student_count'] as num?)?.toInt() ?? 0,
      )).toList();

      state = loaded;
    } catch (e) {
      debugPrint('Supabase load classes error: $e');
    }
  }

  Future<TeacherClass> addClass({
    required String title,
    required String department,
    String? customCode,
  }) async {
    // Generate clean 6-char code if none provided
    final autoCode = customCode?.trim().toUpperCase().isNotEmpty == true
        ? customCode!.trim().toUpperCase()
        : '${department.length >= 3 ? department.substring(0, 3).toUpperCase() : "CLS"}-${(100 + DateTime.now().millisecond % 900)}';

    String classId = 'class-${DateTime.now().millisecondsSinceEpoch}';

    final client = _client;
    if (client != null) {
      final instructorName = client.auth.currentUser?.userMetadata?['name'] ?? 'Faculty Instructor';
      final instructorId = client.auth.currentUser?.id;

      final insertData = {
        'title': title,
        'department': department,
        'code': autoCode,
        'instructor_name': instructorName,
        'instructor_id': instructorId,
        'student_count': 0,
      };

      final res = await client.from('classes').insert(insertData).select().maybeSingle();
      if (res != null && res['id'] != null) {
        classId = res['id'].toString();
      }
    }

    final newClass = TeacherClass(
      id: classId,
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
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  List<LessonModel> build() {
    _loadFromSupabase();
    return const [];
  }

  Future<void> _loadFromSupabase() async {
    final client = _client;
    if (client == null) return;
    try {
      final res = await client
          .from('lessons')
          .select()
          .order('created_at', ascending: false);

      final loaded = (res as List).map((l) {
        final objs = (l['objectives'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final quizzes = (l['quiz_questions'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final rawAttachments = l['attachments'];
        List<LessonAttachment> attList = [];
        if (rawAttachments is List) {
          attList = rawAttachments
              .whereType<Map>()
              .map((a) => LessonAttachment.fromJson(Map<String, dynamic>.from(a)))
              .toList();
        }
        final created = DateTime.tryParse(l['created_at']?.toString() ?? '') ?? DateTime.now();

        return LessonModel(
          id: l['id'].toString(),
          classId: l['class_id']?.toString() ?? '',
          className: l['class_name']?.toString() ?? '',
          title: l['title']?.toString() ?? '',
          content: l['content']?.toString() ?? '',
          estimatedMinutes: l['estimated_minutes']?.toString() ?? '45 mins',
          objectives: objs,
          quizQuestions: quizzes,
          attachments: attList,
          createdAt: created,
        );
      }).toList();

      state = loaded;
    } catch (e) {
      debugPrint('Supabase load lessons error: $e');
    }
  }

  Future<LessonModel> addLesson({
    required String classId,
    required String className,
    required String title,
    required String content,
    required String estimatedMinutes,
    List<String> objectives = const [],
    List<String> quizQuestions = const [],
    List<LessonAttachment> attachments = const [],
  }) async {
    String lessonId = 'lesson-${DateTime.now().millisecondsSinceEpoch}';

    final client = _client;
    if (client != null) {
      try {
        final insertData = {
          'class_id': classId.startsWith('class-') ? null : classId,
          'class_name': className,
          'title': title,
          'content': content,
          'estimated_minutes': estimatedMinutes,
          'objectives': objectives,
          'quiz_questions': quizQuestions,
          'attachments': attachments.map((a) => a.toJson()).toList(),
        };

        final res = await client.from('lessons').insert(insertData).select().maybeSingle();
        if (res != null && res['id'] != null) {
          lessonId = res['id'].toString();
        }
      } catch (e) {
        // Fallback without attachments column if table schema not updated yet
        try {
          final fallbackData = {
            'class_id': classId.startsWith('class-') ? null : classId,
            'class_name': className,
            'title': title,
            'content': content,
            'estimated_minutes': estimatedMinutes,
            'objectives': objectives,
            'quiz_questions': quizQuestions,
          };
          final res = await client.from('lessons').insert(fallbackData).select().maybeSingle();
          if (res != null && res['id'] != null) {
            lessonId = res['id'].toString();
          }
        } catch (inner) {
          debugPrint('Supabase insert lesson fallback error: $inner');
        }
        debugPrint('Supabase insert lesson error: $e');
      }
    }

    final newLesson = LessonModel(
      id: lessonId,
      classId: classId,
      className: className,
      title: title,
      content: content,
      estimatedMinutes: estimatedMinutes,
      objectives: objectives,
      quizQuestions: quizQuestions,
      attachments: attachments,
      createdAt: DateTime.now(),
    );
    state = [newLesson, ...state];
    return newLesson;
  }
}

final teacherLessonsProvider =
    NotifierProvider<TeacherLessonNotifier, List<LessonModel>>(() {
  return TeacherLessonNotifier();
});
