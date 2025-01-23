import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/model/user_id_model.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';
import 'package:trading_game_flutter/widgets/orders_graph_widget.dart'; // Replace with the actual path of your provider

class AutoUpdateTestScreen extends StatefulWidget {
  @override
  _AutoUpdateTestScreenState createState() => _AutoUpdateTestScreenState();
}

class _AutoUpdateTestScreenState extends State<AutoUpdateTestScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      final random = Random();
      var marketPrice = random.nextInt(60) + 20;
      var sellOrders = List.generate(20, (index) {
        return Order(
            price: marketPrice + random.nextInt(10),
            type: TradeType.sell,
            userId: UserId(id: ''),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            executedAt: null);
      });
      var buyOrders = List.generate(20, (index) {
        return Order(
            price: marketPrice - random.nextInt(10),
            type: TradeType.buy,
            userId: UserId(id: ''),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            executedAt: null);
      });
      final ordersByPrice = {
        for (var price in [
          ...sellOrders.map((order) => order.price),
          ...buyOrders.map((order) => order.price)
        ])
          price: sellOrders.where((order) => order.price == price).toList() +
              buyOrders.where((order) => order.price == price).toList()
      };

      context.read<OrdersProvider>().setActiveOrders(
          ordersByPrice.values.toList().fold([], (acc, curr) => acc + curr));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Graph Auto-Update Test Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: OrdersGraphWidget(),
            ),
            SizedBox(height: 16),
            Text(
              'Data updates every 5 seconds automatically.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
