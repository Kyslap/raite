// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => _ClassModel(
  id: json['id'] as String,
  courseCode: json['courseCode'] as String,
  name: json['name'] as String,
  professor: json['professor'] as String,
  progress: (json['progress'] as num).toDouble(),
  topics:
      (json['topics'] as List<dynamic>?)
          ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ClassModelToJson(_ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseCode': instance.courseCode,
      'name': instance.name,
      'professor': instance.professor,
      'progress': instance.progress,
      'topics': instance.topics,
    };
