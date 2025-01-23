// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      type: $enumDecode(_$TradeTypeEnumMap, json['type']),
      userId: UserId.fromJson(json['userId'] as Map<String, dynamic>),
      price: (json['price'] as num).toInt(),
      createdAt: (json['createdAt'] as num?)?.toInt(),
      executedAt: (json['executedAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'type': _$TradeTypeEnumMap[instance.type]!,
      'userId': instance.userId.toJson(),
      'price': instance.price,
      'createdAt': instance.createdAt,
      'executedAt': instance.executedAt,
    };

const _$TradeTypeEnumMap = {
  TradeType.buy: 'BUY',
  TradeType.sell: 'SELL',
};
