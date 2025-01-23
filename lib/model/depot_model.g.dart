// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'depot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Depot _$DepotFromJson(Map<String, dynamic> json) => Depot(
      userId: UserId.fromJson(json['userId'] as Map<String, dynamic>),
      stockAmount: (json['stockAmount'] as num).toInt(),
      balance: (json['balance'] as num).toInt(),
    );

Map<String, dynamic> _$DepotToJson(Depot instance) => <String, dynamic>{
      'userId': instance.userId.toJson(),
      'stockAmount': instance.stockAmount,
      'balance': instance.balance,
    };
