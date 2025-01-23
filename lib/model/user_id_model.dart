import 'package:json_annotation/json_annotation.dart';

part 'user_id_model.g.dart';

@JsonSerializable()
class UserId {
  final String id;

  UserId({required this.id});

  factory UserId.fromJson(Map<String, dynamic> json) => _$UserIdFromJson(json);
  Map<String, dynamic> toJson() => _$UserIdToJson(this);
}