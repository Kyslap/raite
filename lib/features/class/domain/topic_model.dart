import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic_model.freezed.dart';
part 'topic_model.g.dart';

@freezed
abstract class TopicModel with _$TopicModel {
  const factory TopicModel({
    required String id,
    required String title,
    required String description,
  }) = _TopicModel;

  factory TopicModel.fromJson(Map<String, dynamic> json) => _$TopicModelFromJson(json);
}
