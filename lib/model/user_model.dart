import 'package:json_annotation/json_annotation.dart';
import 'user_id_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final UserId userId;
  final String? name;
  final UserStatus status;

  User({
    required this.userId,
    this.name,
    required this.status,
  });

  UserId get id => userId;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonEnum(valueField: 'desc')
enum UserStatus {
  pendingActivation("PENDING_ACTIVATION"),
  active("ACTIVE"),
  inactive("INACTIVE");

  const UserStatus(this.desc);
  final String desc;
}