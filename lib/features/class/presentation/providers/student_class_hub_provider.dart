import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/student_submission_model.dart';
import '../../../teacher/presentation/providers/teacher_class_hub_provider.dart';

class StudentSubmissionsNotifier extends Notifier<Map<String, StudentSubmissionModel>> {
  @override
  Map<String, StudentSubmissionModel> build() {
    return {
      'asg-demo-1': StudentSubmissionModel(
        id: 'sub-1',
        assignmentId: 'asg-demo-1',
        classId: 'class-1',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(hours: 14)),
        note: 'Completed Project Charter, Stakeholder RACI matrix, and 3-level WBS breakdown.',
        attachedFileName: 'Project_Charter_AlexRivera.pdf',
        status: 'graded',
        grade: '96 / 100',
        feedback: 'Outstanding work on the WBS decomposition and risk mitigation plan!',
      ),
      'sample-asg-2': StudentSubmissionModel(
        id: 'sub-sample-2',
        assignmentId: 'sample-asg-2',
        classId: 'class-1',
        studentId: 'stu-101',
        studentName: 'Alex Rivera',
        studentEmail: 'alex.rivera@raite.edu',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        note: 'Completed Sprint Planning retrospective and Critical Path Network Diagram.',
        attachedFileName: 'CPM_Network_Diagram_Alex.pdf',
        status: 'submitted',
      ),
    };
  }

  void submitAssignment({
    required String assignmentId,
    required String classId,
    String note = '',
    String? attachedFileName,
    String studentName = 'Alex Rivera',
    String studentEmail = 'alex.rivera@raite.edu',
  }) {
    final subId = 'sub-${DateTime.now().millisecondsSinceEpoch}';
    final newSub = StudentSubmissionModel(
      id: subId,
      assignmentId: assignmentId,
      classId: classId,
      studentId: 'stu-101',
      studentName: studentName,
      studentEmail: studentEmail,
      submittedAt: DateTime.now(),
      note: note,
      attachedFileName: attachedFileName,
      status: 'submitted',
    );

    state = {
      ...state,
      assignmentId: newSub,
    };

    // Reactively push into Teacher Submissions so instructor immediately sees it
    ref.read(teacherSubmissionsProvider.notifier).recordSubmission(newSub);
  }

  void unsubmitAssignment(String assignmentId) {
    final updated = Map<String, StudentSubmissionModel>.from(state);
    final removed = updated.remove(assignmentId);
    state = updated;

    if (removed != null) {
      ref.read(teacherSubmissionsProvider.notifier).removeSubmission(
            assignmentId: assignmentId,
            studentId: 'stu-101',
          );
    }
  }

  void updateGradedSubmission(StudentSubmissionModel gradedSub) {
    state = {
      ...state,
      gradedSub.assignmentId: gradedSub,
    };
  }

  bool isSubmitted(String assignmentId) {
    return state.containsKey(assignmentId);
  }

  StudentSubmissionModel? getSubmission(String assignmentId) {
    return state[assignmentId];
  }
}

final studentSubmissionsProvider =
    NotifierProvider<StudentSubmissionsNotifier, Map<String, StudentSubmissionModel>>(() {
  return StudentSubmissionsNotifier();
});

class AnnouncementRepliesNotifier extends Notifier<List<AnnouncementReplyModel>> {
  @override
  List<AnnouncementReplyModel> build() {
    return [
      AnnouncementReplyModel(
        id: 'reply-1',
        announcementId: 'ann-sample-1',
        authorName: 'Alex Rivera (You)',
        authorRole: 'Student',
        content: 'Thank you for the update! Will the lecture slides be posted before class?',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AnnouncementReplyModel(
        id: 'reply-2',
        announcementId: 'ann-sample-1',
        authorName: 'Prof. Jenkins',
        authorRole: 'Instructor',
        content: 'Yes Alex, slides and notes are available in the Materials tab.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void addReply({
    required String announcementId,
    required String content,
    String authorName = 'Alex Rivera (You)',
  }) {
    if (content.trim().isEmpty) return;

    final newReply = AnnouncementReplyModel(
      id: 'reply-${DateTime.now().millisecondsSinceEpoch}',
      announcementId: announcementId,
      authorName: authorName,
      authorRole: 'Student',
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    state = [...state, newReply];
  }
}

final announcementRepliesProvider =
    NotifierProvider<AnnouncementRepliesNotifier, List<AnnouncementReplyModel>>(() {
  return AnnouncementRepliesNotifier();
});

class AnnouncementLikesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  void toggleLike(String announcementId) {
    if (state.contains(announcementId)) {
      state = state.where((id) => id != announcementId).toSet();
    } else {
      state = {...state, announcementId};
    }
  }

  bool isLiked(String announcementId) {
    return state.contains(announcementId);
  }
}

final announcementLikesProvider =
    NotifierProvider<AnnouncementLikesNotifier, Set<String>>(() {
  return AnnouncementLikesNotifier();
});
