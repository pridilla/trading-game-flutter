// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: UserId.fromJson(json['userId'] as Map<String, dynamic>),
      name: json['name'] as String?,
      status: $enumDecode(_$UserStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId.toJson(),
      'name': instance.name,
      'status': _$UserStatusEnumMap[instance.status]!,
    };

const _$UserStatusEnumMap = {
  UserStatus.pendingActivation: 'PENDING_ACTIVATION',
  UserStatus.active: 'ACTIVE',
  UserStatus.inactive: 'INACTIVE',
};
