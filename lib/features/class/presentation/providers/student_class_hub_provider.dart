import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/student_submission_model.dart';

class StudentSubmissionsNotifier extends Notifier<Map<String, StudentSubmissionModel>> {
  @override
  Map<String, StudentSubmissionModel> build() {
    return {
      'demo-sub-1': StudentSubmissionModel(
        assignmentId: 'demo-asg-3',
        classId: 'math-101',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        note: 'Submitted all proofs for Chapter 3. Verified using theorem 4.2.',
        attachedFileName: 'Tensor_Calculus_Lab3_Proofs.pdf',
        status: 'graded',
        grade: '98 / 100 (A+)',
      ),
    };
  }

  void submitAssignment({
    required String assignmentId,
    required String classId,
    String note = '',
    String? attachedFileName,
  }) {
    final newSub = StudentSubmissionModel(
      assignmentId: assignmentId,
      classId: classId,
      submittedAt: DateTime.now(),
      note: note,
      attachedFileName: attachedFileName,
      status: 'submitted',
    );

    state = {
      ...state,
      assignmentId: newSub,
    };
  }

  void unsubmitAssignment(String assignmentId) {
    final updated = Map<String, StudentSubmissionModel>.from(state);
    updated.remove(assignmentId);
    state = updated;
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
