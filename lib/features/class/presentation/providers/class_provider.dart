import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/class_model.dart';
import '../../domain/topic_model.dart';
import '../../data/mock_class_repository.dart';
import '../../../teacher/presentation/providers/teacher_lesson_provider.dart';

class JoinClassResult {
  final bool success;
  final String message;
  final ClassModel? classModel;

  const JoinClassResult({
    required this.success,
    required this.message,
    this.classModel,
  });
}

final classRepositoryProvider = Provider((ref) => MockClassRepository());

// System-wide registry of classes that students can join
class AllAvailableClassesNotifier extends Notifier<List<ClassModel>> {
  @override
  List<ClassModel> build() {
    return const [];
  }

  void registerClass(ClassModel newClass) {
    state = [newClass, ...state];
  }
}

final allAvailableClassesProvider =
    NotifierProvider<AllAvailableClassesNotifier, List<ClassModel>>(() {
  return AllAvailableClassesNotifier();
});

class EnrolledClassesNotifier extends AsyncNotifier<List<ClassModel>> {
  @override
  Future<List<ClassModel>> build() async {
    final repository = ref.read(classRepositoryProvider);
    return repository.fetchEnrolledClasses();
  }

  Future<JoinClassResult> joinClassByCode(String inputCode) async {
    final cleanCode = inputCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return const JoinClassResult(
        success: false,
        message: 'Please enter a valid class code.',
      );
    }

    final currentList = state.value ?? [];

    // Check if student is already enrolled in this code
    final alreadyJoined = currentList.any(
      (c) => c.courseCode.trim().toUpperCase() == cleanCode,
    );
    if (alreadyJoined) {
      return const JoinClassResult(
        success: false,
        message: 'You are already enrolled in this class!',
      );
    }

    ClassModel? foundClass;

    // Search in Supabase first
    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('classes')
          .select()
          .ilike('code', cleanCode)
          .maybeSingle();

      if (res != null) {
        final classId = res['id'].toString();
        List<TopicModel> topics = [];
        try {
          final lessonsRes = await client
              .from('lessons')
              .select()
              .eq('class_id', classId);
          topics = (lessonsRes as List)
              .map((l) => TopicModel(
                    id: l['id'].toString(),
                    title: l['title']?.toString() ?? 'Topic',
                    description: l['content']?.toString() ?? '',
                  ))
              .toList();
        } catch (_) {}

        if (topics.isEmpty) {
          topics = [
            TopicModel(
              id: 'topic-$classId',
              title: 'Introduction & Foundations',
              description: '${res['department'] ?? 'Course'} curriculum and syllabus',
            ),
          ];
        }

        foundClass = ClassModel(
          id: classId,
          courseCode: res['code']?.toString() ?? cleanCode,
          name: res['title']?.toString() ?? 'Class',
          professor: res['instructor_name']?.toString() ?? 'Academic Faculty',
          progress: 0.0,
          topics: topics,
        );

        // Record in Supabase user_classes if authenticated
        final userId = client.auth.currentUser?.id;
        if (userId != null) {
          try {
            await client.from('user_classes').upsert({
              'user_id': userId,
              'class_id': classId,
              'progress_percentage': 0,
            });
          } catch (_) {}
        }
      }
    } catch (_) {}

    // Search in system catalog
    if (foundClass == null) {
      final allCatalog = ref.read(allAvailableClassesProvider);
      for (final c in allCatalog) {
        if (c.courseCode.trim().toUpperCase() == cleanCode) {
          foundClass = c;
          break;
        }
      }
    }

    // Also check any newly created teacher classes from teacherClassesProvider
    if (foundClass == null) {
      final teacherClasses = ref.read(teacherClassesProvider);
      for (final tc in teacherClasses) {
        if (tc.code.trim().toUpperCase() == cleanCode) {
          final teacherLessons = ref.read(teacherLessonsProvider);
          final classLessons = teacherLessons.where((l) => l.classId == tc.id).toList();

          final topics = classLessons.isNotEmpty
              ? classLessons
                  .map((l) => TopicModel(
                        id: l.id,
                        title: l.title,
                        description: l.content,
                      ))
                  .toList()
              : [
                  TopicModel(
                    id: 'topic-${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Course Introduction & Fundamentals',
                    description: '${tc.department} core curriculum and syllabus overview',
                  ),
                ];

          foundClass = ClassModel(
            id: tc.id,
            courseCode: tc.code,
            name: tc.title,
            professor: 'Academic Faculty',
            progress: 0.0,
            topics: topics,
          );
          break;
        }
      }
    }

    if (foundClass == null) {
      return JoinClassResult(
        success: false,
        message: 'No active class found with code "$cleanCode". Ask your instructor.',
      );
    }

    // Add to student enrolled list
    state = AsyncData([foundClass, ...currentList]);

    return JoinClassResult(
      success: true,
      message: 'Successfully enrolled in ${foundClass.name}!',
      classModel: foundClass,
    );
  }
}

final enrolledClassesProvider =
    AsyncNotifierProvider<EnrolledClassesNotifier, List<ClassModel>>(() {
  return EnrolledClassesNotifier();
});

final classDetailProvider = Provider.family<ClassModel?, String>((ref, id) {
  final classes = ref.watch(enrolledClassesProvider);
  return classes.maybeWhen(
    data: (list) {
      try {
        return list.firstWhere((c) => c.id == id);
      } catch (e) {
        return null;
      }
    },
    orElse: () => null,
  );
});
