
import 'package:json_annotation/json_annotation.dart';

part 'remaining_duration_response_model.g.dart';

@JsonSerializable()
class RemainingDurationResponse {
  final int remainingSeconds;

  RemainingDurationResponse({required this.remainingSeconds});
}