import 'package:freezed_annotation/freezed_annotation.dart';
import 'topic_model.dart';

part 'class_model.freezed.dart';
part 'class_model.g.dart';

@freezed
abstract class ClassModel with _$ClassModel {
  const factory ClassModel({
    required String id,
    required String courseCode,
    required String name,
    required String professor,
    required double progress,
    @Default([]) List<TopicModel> topics,
  }) = _ClassModel;

  factory ClassModel.fromJson(Map<String, dynamic> json) => _$ClassModelFromJson(json);
}
