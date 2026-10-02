import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/announcement_model.dart';
import '../../domain/assignment_model.dart';
import '../../../class/domain/student_submission_model.dart';
import 'teacher_lesson_provider.dart';

class ClassAnnouncementsNotifier extends Notifier<List<AnnouncementModel>> {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  List<AnnouncementModel> build() {
    _loadFromSupabase();
    return const [];
  }

  Future<void> _loadFromSupabase() async {
    final client = _client;
    if (client == null) return;
    try {
      final res = await client
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      final loaded = (res as List)
          .map((a) => AnnouncementModel.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList();

      state = loaded;
    } catch (e) {
      debugPrint('Supabase load announcements error: $e');
    }
  }

  Future<AnnouncementModel> addAnnouncement({
    required String classId,
    required String title,
    required String content,
    String authorName = 'Faculty Instructor',
    bool isPinned = false,
  }) async {
    String id = 'ann-${DateTime.now().millisecondsSinceEpoch}';

    final client = _client;
    if (client != null) {
      try {
        final insertData = {
          'class_id': classId.startsWith('class-') ? null : classId,
          'title': title,
          'content': content,
          'author_name': authorName,
          'is_pinned': isPinned,
        };
        final res = await client.from('announcements').insert(insertData).select().maybeSingle();
        if (res != null && res['id'] != null) {
          id = res['id'].toString();
        }
      } catch (e) {
        debugPrint('Supabase insert announcement error: $e');
      }
    }

    final newAnn = AnnouncementModel(
      id: id,
      classId: classId,
      title: title,
      content: content,
      authorName: authorName,
      isPinned: isPinned,
      createdAt: DateTime.now(),
    );

    state = [newAnn, ...state];
    return newAnn;
  }

  Future<void> deleteAnnouncement(String id) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('announcements').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase delete announcement error: $e');
      }
    }
    state = state.where((a) => a.id != id).toList();
  }
}

final classAnnouncementsProvider =
    NotifierProvider<ClassAnnouncementsNotifier, List<AnnouncementModel>>(() {
  return ClassAnnouncementsNotifier();
});

class ClassAssignmentsNotifier extends Notifier<List<AssignmentModel>> {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  List<AssignmentModel> build() {
    _loadFromSupabase();
    return const [];
  }

  Future<void> _loadFromSupabase() async {
    final client = _client;
    if (client == null) return;
    try {
      final res = await client
          .from('assignments')
          .select()
          .order('created_at', ascending: false);

      final loaded = (res as List)
          .map((a) => AssignmentModel.fromJson(Map<String, dynamic>.from(a as Map)))
          .toList();

      state = loaded;
    } catch (e) {
      debugPrint('Supabase load assignments error: $e');
    }
  }

  Future<AssignmentModel> addAssignment({
    required String classId,
    required String title,
    required String instructions,
    int points = 100,
    required String dueDate,
    String category = 'Homework',
  }) async {
    String id = 'asg-${DateTime.now().millisecondsSinceEpoch}';

    final client = _client;
    if (client != null) {
      try {
        final insertData = {
          'class_id': classId.startsWith('class-') ? null : classId,
          'title': title,
          'instructions': instructions,
          'points': points,
          'due_date': dueDate,
          'category': category,
          'submissions_count': 0,
        };
        final res = await client.from('assignments').insert(insertData).select().maybeSingle();
        if (res != null && res['id'] != null) {
          id = res['id'].toString();
        }
      } catch (e) {
        debugPrint('Supabase insert assignment error: $e');
      }
    }

    final newAsg = AssignmentModel(
      id: id,
      classId: classId,
      title: title,
      instructions: instructions,
      points: points,
      dueDate: dueDate,
      category: category,
      submissionsCount: 0,
      createdAt: DateTime.now(),
    );

    state = [newAsg, ...state];
    return newAsg;
  }

  Future<void> deleteAssignment(String id) async {
    final client = _client;
    if (client != null) {
      try {
        await client.from('assignments').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase delete assignment error: $e');
      }
    }
    state = state.where((a) => a.id != id).toList();
  }
}

final classAssignmentsProvider =
    NotifierProvider<ClassAssignmentsNotifier, List<AssignmentModel>>(() {
  return ClassAssignmentsNotifier();
});

class TeacherSubmissionsNotifier extends Notifier<List<StudentSubmissionModel>> {
  @override
  List<StudentSubmissionModel> build() {
    return [
      StudentSubmissionModel(
        id: 'sub-1',
        assignmentId: 'asg-demo-1',
        classId: 'math-101',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 14)),
        note: 'Completed all problems and double checked convergence tests in section 4.',
        attachedFileName: 'Problem_Set_1_AlexRivera.pdf',
        status: 'graded',
        grade: '96',
        feedback: 'Outstanding work on the Taylor series approximations!',
      ),
      StudentSubmissionModel(
        id: 'sub-2',
        assignmentId: 'asg-demo-1',
        classId: 'math-101',
        studentId: 'stu-102',
        studentName: 'Sophia Martinez',
        studentEmail: 'sophia.m@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        note: 'Here is my assignment. Verified proofs with peer review.',
        attachedFileName: 'Calculus_Worksheet_SophiaM.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-3',
        assignmentId: 'asg-demo-1',
        classId: 'math-101',
        studentId: 'stu-103',
        studentName: 'Marcus Vance',
        studentEmail: 'marcus.v@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'Attached the derivation formulas and summary notes.',
        attachedFileName: 'Derivatives_Lab_Vance.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-4',
        assignmentId: 'asg-demo-1',
        classId: 'math-101',
        studentId: 'stu-104',
        studentName: 'Chloe Bennett',
        studentEmail: 'chloe.b@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: '',
        status: 'missing',
        grade: null,
        feedback: null,
      ),
    ];
  }

  void gradeSubmission({
    required String submissionId,
    required String grade,
    String? feedback,
  }) {
    state = state.map((sub) {
      if (sub.id == submissionId) {
        return sub.copyWith(
          grade: grade,
          feedback: feedback,
          status: 'graded',
        );
      }
      return sub;
    }).toList();
  }

  void recordSubmission(StudentSubmissionModel sub) {
    state = [
      sub,
      ...state.where((s) => s.id != sub.id && !(s.assignmentId == sub.assignmentId && s.studentId == sub.studentId)),
    ];
  }
}

final teacherSubmissionsProvider =
    NotifierProvider<TeacherSubmissionsNotifier, List<StudentSubmissionModel>>(() {
  return TeacherSubmissionsNotifier();
});

class SelectedTeacherClassNotifier extends Notifier<TeacherClass?> {
  @override
  TeacherClass? build() => null;

  void selectClass(TeacherClass? cls) {
    state = cls;
  }
}

final selectedTeacherClassProvider =
    NotifierProvider<SelectedTeacherClassNotifier, TeacherClass?>(
  SelectedTeacherClassNotifier.new,
);
