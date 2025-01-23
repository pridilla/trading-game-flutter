import 'package:flutter/material.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/model/user_id_model.dart';

class OrdersProvider extends ChangeNotifier {
  List<Order> _activeOrders = [];
  List<Order> _executedOrders = [];

  List<Order> get activeOrders => _activeOrders;
  List<Order> get executedOrders => _executedOrders;

  void setActiveOrders(List<Order> orders) {
    _activeOrders = orders;
    notifyListeners();
  }

  void setExecutedOrders(List<Order> orders) {
    _executedOrders = orders;
    notifyListeners();
  }

  Map<int, List<Order>> getBuyOrdersByPrice() {
    var buyOrders = _activeOrders.where((order) => order.type == TradeType.buy);
    return {
      for (var price in buyOrders.map((order) => order.price))
        price: buyOrders.where((order) => order.price == price).toList()
    };
  }

  Map<int, List<Order>> getSellOrdersByPrice() {
    var sellOrders =
        _activeOrders.where((order) => order.type == TradeType.sell);
    return {
      for (var price in sellOrders.map((order) => order.price))
        price: sellOrders.where((order) => order.price == price).toList()
    };
  }

  Map<int, List<Order>> getOrdersByPrice() {
    return {
      for (var price in _activeOrders.map((order) => order.price))
        price: _activeOrders.where((order) => order.price == price).toList()
    };
  }

  List<Order> getUserOrders(UserId userId) {
    return _activeOrders.where((order) => order.userId.id == userId.id).toList();
  }

  int? getLastPrice() {
    _executedOrders.sort((a, b) => a.executedAt!.compareTo(b.executedAt!));
    return _executedOrders.isNotEmpty ? _executedOrders.last.price : null;
  }
}
