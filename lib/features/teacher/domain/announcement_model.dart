class AnnouncementModel {
  final String id;
  final String classId;
  final String title;
  final String content;
  final String authorName;
  final bool isPinned;
  final DateTime createdAt;

  const AnnouncementModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.content,
    this.authorName = 'Professor',
    this.isPinned = false,
    required this.createdAt,
  });

  AnnouncementModel copyWith({
    String? id,
    String? classId,
    String? title,
    String? content,
    String? authorName,
    bool? isPinned,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'class_id': classId,
    'title': title,
    'content': content,
    'author_name': authorName,
    'is_pinned': isPinned,
    'created_at': createdAt.toIso8601String(),
  };

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => AnnouncementModel(
    id: json['id']?.toString() ?? '',
    classId: json['class_id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    content: json['content']?.toString() ?? '',
    authorName: json['author_name']?.toString() ?? 'Professor',
    isPinned: json['is_pinned'] == true,
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
  );
}
