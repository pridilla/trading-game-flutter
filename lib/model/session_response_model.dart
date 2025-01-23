import 'package:json_annotation/json_annotation.dart';

part 'session_response_model.g.dart';

@JsonSerializable()
class SessionResponse {
  final String sessionId;
  final int remainingSeconds;
  final SessionState sessionState;

  SessionResponse({required this.sessionId, required this.remainingSeconds, required this.sessionState});

  factory SessionResponse.fromJson(Map<String, dynamic> json) => _$SessionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);
}

@JsonEnum(valueField: 'sessionState')
enum SessionState {
  pending("PENDING"),
  active("ACTIVE"),
  finished("FINISHED");

  final String sessionState;

  const SessionState(this.sessionState);
}