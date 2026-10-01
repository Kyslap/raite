class LessonAttachment {
  final String id;
  final String name;
  final String fileType; // 'pdf', 'ppt', 'pptx', 'doc', 'docx', 'other'
  final int sizeBytes;
  final String? path;
  final String? url;

  const LessonAttachment({
    required this.id,
    required this.name,
    required this.fileType,
    required this.sizeBytes,
    this.path,
    this.url,
  });

  String get formattedSize {
    if (sizeBytes <= 0) return '';
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fileType': fileType,
    'sizeBytes': sizeBytes,
    'path': path,
    'url': url,
  };

  factory LessonAttachment.fromJson(Map<String, dynamic> json) => LessonAttachment(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? 'Attachment',
    fileType: json['fileType']?.toString() ?? 'file',
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    path: json['path']?.toString(),
    url: json['url']?.toString(),
  );
}

class LessonModel {
  final String id;
  final String classId;
  final String className;
  final String title;
  final String content;
  final String estimatedMinutes;
  final List<String> objectives;
  final List<String> quizQuestions;
  final List<LessonAttachment> attachments;
  final DateTime createdAt;

  const LessonModel({
    required this.id,
    required this.classId,
    required this.className,
    required this.title,
    required this.content,
    required this.estimatedMinutes,
    this.objectives = const [],
    this.quizQuestions = const [],
    this.attachments = const [],
    required this.createdAt,
  });

  LessonModel copyWith({
    String? id,
    String? classId,
    String? className,
    String? title,
    String? content,
    String? estimatedMinutes,
    List<String>? objectives,
    List<String>? quizQuestions,
    List<LessonAttachment>? attachments,
    DateTime? createdAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      title: title ?? this.title,
      content: content ?? this.content,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      objectives: objectives ?? this.objectives,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

