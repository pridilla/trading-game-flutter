import 'package:json_annotation/json_annotation.dart';
import 'package:trading_game_flutter/model/user_id_model.dart';

part 'depot_model.g.dart';

@JsonSerializable()
class Depot{
  final UserId userId;
  final int stockAmount;
  final int balance;

  Depot({required this.userId, required this.stockAmount, required this.balance});

  factory Depot.fromJson(Map<String, dynamic> json) => _$DepotFromJson(json);
  Map<String, dynamic> toJson() => _$DepotToJson(this);
}