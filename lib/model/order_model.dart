import 'package:json_annotation/json_annotation.dart';
import 'package:trading_game_flutter/model/user_id_model.dart';

part 'order_model.g.dart';

@JsonSerializable()
class Order {
  final TradeType type;
  final UserId userId;
  final int price;
  final int? createdAt;
  final int? executedAt;

  Order(
      {required this.type,
      required this.userId,
      required this.price,
      required this.createdAt,
      required this.executedAt});

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonEnum(valueField: 'type')
enum TradeType {
  buy("BUY"),
  sell("SELL");

  final String type;

  const TradeType(this.type);
}
