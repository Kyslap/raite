// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TopicModel _$TopicModelFromJson(Map<String, dynamic> json) => _TopicModel(
  id: json['id'] as String,
  classId: json['classId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$TopicModelToJson(_TopicModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'title': instance.title,
      'description': instance.description,
    };
