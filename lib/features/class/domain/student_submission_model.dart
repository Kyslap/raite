class StudentSubmissionModel {
  final String assignmentId;
  final String classId;
  final DateTime submittedAt;
  final String note;
  final String? attachedFileName;
  final String status; // 'submitted', 'graded', 'late'
  final String? grade;

  const StudentSubmissionModel({
    required this.assignmentId,
    required this.classId,
    required this.submittedAt,
    this.note = '',
    this.attachedFileName,
    this.status = 'submitted',
    this.grade,
  });

  Map<String, dynamic> toJson() => {
    'assignment_id': assignmentId,
    'class_id': classId,
    'submitted_at': submittedAt.toIso8601String(),
    'note': note,
    'attached_file_name': attachedFileName,
    'status': status,
    'grade': grade,
  };

  factory StudentSubmissionModel.fromJson(Map<String, dynamic> json) => StudentSubmissionModel(
    assignmentId: json['assignment_id']?.toString() ?? '',
    classId: json['class_id']?.toString() ?? '',
    submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
    note: json['note']?.toString() ?? '',
    attachedFileName: json['attached_file_name']?.toString(),
    status: json['status']?.toString() ?? 'submitted',
    grade: json['grade']?.toString(),
  );
}

class AnnouncementReplyModel {
  final String id;
  final String announcementId;
  final String authorName;
  final String authorRole; // 'Student', 'Instructor', 'Teaching Assistant'
  final String content;
  final DateTime createdAt;

  const AnnouncementReplyModel({
    required this.id,
    required this.announcementId,
    required this.authorName,
    this.authorRole = 'Student',
    required this.content,
    required this.createdAt,
  });
}
