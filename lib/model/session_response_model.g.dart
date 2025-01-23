// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    SessionResponse(
      sessionId: json['sessionId'] as String,
      remainingSeconds: (json['remainingSeconds'] as num).toInt(),
      sessionState: $enumDecode(_$SessionStateEnumMap, json['sessionState']),
    );

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'remainingSeconds': instance.remainingSeconds,
      'sessionState': _$SessionStateEnumMap[instance.sessionState]!,
    };

const _$SessionStateEnumMap = {
  SessionState.pending: 'PENDING',
  SessionState.active: 'ACTIVE',
  SessionState.finished: 'FINISHED',
};
