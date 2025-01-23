

import 'package:json_annotation/json_annotation.dart';

part 'remaining_duration_response.g.dart';

@JsonSerializable()
class RemainingDurationResponse {
  final int remainingSeconds;

  RemainingDurationResponse({
    required this.remainingSeconds,
  });

  factory RemainingDurationResponse.fromJson(Map<String, dynamic> json) => _$RemainingDurationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RemainingDurationResponseToJson(this);
}