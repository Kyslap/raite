class AssignmentModel {
  final String id;
  final String classId;
  final String title;
  final String instructions;
  final int points;
  final String dueDate;
  final String category; // 'Homework', 'Project', 'Quiz', 'Lab'
  final int submissionsCount;
  final DateTime createdAt;

  const AssignmentModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.instructions,
    this.points = 100,
    required this.dueDate,
    this.category = 'Homework',
    this.submissionsCount = 0,
    required this.createdAt,
  });

  AssignmentModel copyWith({
    String? id,
    String? classId,
    String? title,
    String? instructions,
    int? points,
    String? dueDate,
    String? category,
    int? submissionsCount,
    DateTime? createdAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      instructions: instructions ?? this.instructions,
      points: points ?? this.points,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      submissionsCount: submissionsCount ?? this.submissionsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'class_id': classId,
    'title': title,
    'instructions': instructions,
    'points': points,
    'due_date': dueDate,
    'category': category,
    'submissions_count': submissionsCount,
    'created_at': createdAt.toIso8601String(),
  };

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
    id: json['id']?.toString() ?? '',
    classId: json['class_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    instructions: json['instructions']?.toString() ?? '',
    points: (json['points'] as num?)?.toInt() ?? 100,
    dueDate: json['due_date']?.toString() ?? 'Next Week',
    category: json['category']?.toString() ?? 'Homework',
    submissionsCount: (json['submissions_count'] as num?)?.toInt() ?? 0,
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
  );
}
