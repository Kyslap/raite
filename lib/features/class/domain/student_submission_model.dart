class StudentSubmissionModel {
  final String id;
  final String assignmentId;
  final String classId;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final DateTime submittedAt;
  final String note;
  final String? attachedFileName;
  final String? fileUrl;
  final String status; // 'submitted', 'graded', 'late', 'missing'
  final String? grade;
  final String? feedback;

  const StudentSubmissionModel({
    this.id = '',
    required this.assignmentId,
    required this.classId,
    this.studentId = 'stu-1',
    this.studentName = 'Alex Rivera',
    this.studentEmail = 'alex.rivera@raite.edu',
    required this.submittedAt,
    this.note = '',
    this.attachedFileName,
    this.fileUrl,
    this.status = 'submitted',
    this.grade,
    this.feedback,
  });

  StudentSubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? classId,
    String? studentId,
    String? studentName,
    String? studentEmail,
    DateTime? submittedAt,
    String? note,
    String? attachedFileName,
    String? fileUrl,
    String? status,
    String? grade,
    String? feedback,
  }) {
    return StudentSubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      submittedAt: submittedAt ?? this.submittedAt,
      note: note ?? this.note,
      attachedFileName: attachedFileName ?? this.attachedFileName,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'assignment_id': assignmentId,
    'class_id': classId,
    'student_id': studentId,
    'student_name': studentName,
    'student_email': studentEmail,
    'submitted_at': submittedAt.toIso8601String(),
    'note': note,
    'attached_file_name': attachedFileName,
    'file_url': fileUrl,
    'status': status,
    'grade': grade,
    'feedback': feedback,
  };

  factory StudentSubmissionModel.fromJson(Map<String, dynamic> json) => StudentSubmissionModel(
    id: json['id']?.toString() ?? '',
    assignmentId: json['assignment_id']?.toString() ?? '',
    classId: json['class_id']?.toString() ?? '',
    studentId: json['student_id']?.toString() ?? 'stu-1',
    studentName: json['student_name']?.toString() ?? 'Alex Rivera',
    studentEmail: json['student_email']?.toString() ?? 'alex.rivera@raite.edu',
    submittedAt: DateTime.tryParse(json['submitted_at']?.toString() ?? '') ?? DateTime.now(),
    note: json['note']?.toString() ?? '',
    attachedFileName: json['attached_file_name']?.toString(),
    fileUrl: json['file_url']?.toString(),
    status: json['status']?.toString() ?? 'submitted',
    grade: json['grade']?.toString(),
    feedback: json['feedback']?.toString(),
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
