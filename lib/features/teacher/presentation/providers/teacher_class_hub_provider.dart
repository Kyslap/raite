import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/announcement_model.dart';
import '../../domain/assignment_model.dart';
import '../../../class/domain/student_submission_model.dart';
import '../../../class/presentation/providers/student_class_hub_provider.dart';
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
      // Class 1 (MATH-201 Calculus)
      StudentSubmissionModel(
        id: 'sub-1',
        assignmentId: 'asg-demo-1',
        classId: 'class-1',
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
        classId: 'class-1',
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
        classId: 'class-1',
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
        classId: 'class-1',
        studentId: 'stu-104',
        studentName: 'Chloe Bennett',
        studentEmail: 'chloe.b@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: '',
        status: 'missing',
        grade: null,
        feedback: null,
      ),
      // Backward compatibility alias for math-101
      StudentSubmissionModel(
        id: 'sub-math-alias',
        assignmentId: 'sample-asg-2',
        classId: 'math-101',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: 'Completed midterm quiz review problems.',
        attachedFileName: 'Quiz_Worksheet_Alex.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      // Class 2 (CS-210 Data Structures & Algorithms)
      StudentSubmissionModel(
        id: 'sub-cs-1',
        assignmentId: 'asg-cs-1',
        classId: 'class-2',
        studentId: 'stu-201',
        studentName: 'David Kim',
        studentEmail: 'david.k@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
        note: 'Implemented AVL balancing with unit tests for double rotations.',
        attachedFileName: 'AVL_Tree_DavidKim.zip',
        status: 'graded',
        grade: '94',
        feedback: 'Clean tree rotation implementation and edge case handling.',
      ),
      StudentSubmissionModel(
        id: 'sub-cs-2',
        assignmentId: 'asg-cs-1',
        classId: 'class-2',
        studentId: 'stu-202',
        studentName: 'Elena Rostova',
        studentEmail: 'elena.r@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
        note: 'BST deletion edge cases tested with graphviz visualization.',
        attachedFileName: 'BST_Elena.tar.gz',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-cs-3',
        assignmentId: 'asg-cs-1',
        classId: 'class-2',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'Completed benchmark analysis on balanced trees.',
        attachedFileName: 'Benchmark_Alex.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-cs-4',
        assignmentId: 'asg-cs-1',
        classId: 'class-2',
        studentId: 'stu-203',
        studentName: 'Jason Lee',
        studentEmail: 'jason.l@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: '',
        status: 'missing',
        grade: null,
        feedback: null,
      ),
      // Class 4 (PM-301 Software Project Management)
      StudentSubmissionModel(
        id: 'sub-pm-1',
        assignmentId: 'asg-pm-1',
        classId: 'class-4',
        studentId: 'stu-301',
        studentName: 'Marcus Brody',
        studentEmail: 'marcus.b@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
        note: 'Earned Value Management calculations and variance chart.',
        attachedFileName: 'EVM_Report_MarcusBrody.pdf',
        status: 'graded',
        grade: '68',
        feedback: 'Revisit Cost Variance vs Schedule Variance formulas in section 3.',
      ),
      StudentSubmissionModel(
        id: 'sub-pm-2',
        assignmentId: 'asg-pm-1',
        classId: 'class-4',
        studentId: 'stu-302',
        studentName: 'Sophia Chen',
        studentEmail: 'sophia.c@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        note: 'Drafted Sprint Retrospective and RACI matrix for agile team.',
        attachedFileName: 'Sprint_Retro_Sophia.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-pm-3',
        assignmentId: 'asg-pm-1',
        classId: 'class-4',
        studentId: 'stu-303',
        studentName: 'Liam Gallagher',
        studentEmail: 'liam.g@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
        note: 'Critical path network diagram with forward and backward passes.',
        attachedFileName: 'CPM_Diagram_Liam.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-pm-4',
        assignmentId: 'asg-pm-1',
        classId: 'class-4',
        studentId: 'stu-304',
        studentName: 'Jordan Reed',
        studentEmail: 'jordan.r@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        note: '',
        status: 'missing',
        grade: null,
        feedback: null,
      ),
      // Class RAITE (1e555c25-04a3-48fc-9dd3-41c86b044909)
      StudentSubmissionModel(
        id: 'sub-raite-1',
        assignmentId: 'asg-raite-1',
        classId: '1e555c25-04a3-48fc-9dd3-41c86b044909',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 12)),
        note: 'Project Charter & Stakeholder Management Plan verified.',
        attachedFileName: 'Project_Charter_Alex.pdf',
        status: 'graded',
        grade: '95',
        feedback: 'Excellent organizational structure breakdown!',
      ),
      StudentSubmissionModel(
        id: 'sub-raite-2',
        assignmentId: 'asg-raite-1',
        classId: '1e555c25-04a3-48fc-9dd3-41c86b044909',
        studentId: 'stu-102',
        studentName: 'Sophia Martinez',
        studentEmail: 'sophia.m@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        note: 'IT systems approach analysis and stakeholder matrix.',
        attachedFileName: 'Stakeholder_Matrix_Sophia.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-raite-3',
        assignmentId: 'asg-raite-1',
        classId: '1e555c25-04a3-48fc-9dd3-41c86b044909',
        studentId: 'stu-104',
        studentName: 'Chloe Bennett',
        studentEmail: 'chloe.b@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'Systems architecture and project lifecycle review.',
        attachedFileName: 'Lifecycle_Chloe.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-raite-4',
        assignmentId: 'asg-raite-1',
        classId: '1e555c25-04a3-48fc-9dd3-41c86b044909',
        studentId: 'stu-103',
        studentName: 'Marcus Vance',
        studentEmail: 'marcus.v@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: '',
        status: 'missing',
        grade: null,
        feedback: null,
      ),
      // Class test (7cfeb75b-b0b6-4de3-b888-bb78b951c90a)
      StudentSubmissionModel(
        id: 'sub-test-1',
        assignmentId: 'asg-test-1',
        classId: '7cfeb75b-b0b6-4de3-b888-bb78b951c90a',
        studentId: 'stu-201',
        studentName: 'David Kim',
        studentEmail: 'david.k@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 9)),
        note: 'File 2 IT context synthesis and Scrum backlogs analysis.',
        attachedFileName: 'File2_Summary_DavidKim.pdf',
        status: 'graded',
        grade: '88',
        feedback: 'Clear distinction between Product Owner and ScrumMaster.',
      ),
      StudentSubmissionModel(
        id: 'sub-test-2',
        assignmentId: 'asg-test-1',
        classId: '7cfeb75b-b0b6-4de3-b888-bb78b951c90a',
        studentId: 'stu-202',
        studentName: 'Elena Rostova',
        studentEmail: 'elena.r@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
        note: 'Agile vs Waterfall case study with prototyping workflow.',
        attachedFileName: 'Agile_Prototyping_Elena.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-test-3',
        assignmentId: 'asg-test-1',
        classId: '7cfeb75b-b0b6-4de3-b888-bb78b951c90a',
        studentId: 'stu-203',
        studentName: 'Jason Lee',
        studentEmail: 'jason.l@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        note: 'Review of systems approach and vernacular study notes.',
        attachedFileName: 'Kapampangan_Review_Jason.pdf',
        status: 'submitted',
        grade: null,
        feedback: null,
      ),
      StudentSubmissionModel(
        id: 'sub-test-4',
        assignmentId: 'asg-test-1',
        classId: '7cfeb75b-b0b6-4de3-b888-bb78b951c90a',
        studentId: 'stu-301',
        studentName: 'Marcus Brody',
        studentEmail: 'marcus.b@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 7)),
        note: 'File 2 reflection and organizational structures exercise.',
        attachedFileName: 'Org_Structures_Marcus.pdf',
        status: 'graded',
        grade: '72',
        feedback: 'Review matrix organization vs functional hierarchy.',
      ),
      StudentSubmissionModel(
        id: 'sub-test-5',
        assignmentId: 'asg-test-1',
        classId: '7cfeb75b-b0b6-4de3-b888-bb78b951c90a',
        studentId: 'stu-304',
        studentName: 'Jordan Reed',
        studentEmail: 'jordan.r@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
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
        final updated = sub.copyWith(
          grade: grade,
          feedback: feedback,
          status: 'graded',
        );
        // Instantly notify student state so Student UI updates in real-time
        ref.read(studentSubmissionsProvider.notifier).updateGradedSubmission(updated);
        return updated;
      }
      return sub;
    }).toList();
  }

  void recordSubmission(StudentSubmissionModel sub) {
    state = [
      sub,
      ...state.where((s) =>
          s.id != sub.id &&
          !(s.assignmentId == sub.assignmentId && s.studentId == sub.studentId)),
    ];
  }

  void removeSubmission({
    required String assignmentId,
    required String studentId,
  }) {
    state = state.where((s) => !(s.assignmentId == assignmentId && s.studentId == studentId)).toList();
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
