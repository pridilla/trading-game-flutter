import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduledModel {
  final String title;
  final String date;

  const ScheduledModel({required this.title, required this.date});
}
