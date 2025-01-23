import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/widgets/last_market_price_widget.dart';
import 'package:trading_game_flutter/widgets/orders_graph_widget.dart';

import '../widgets/timer_widget.dart';

class ActiveGameScreen extends StatelessWidget {

  StreamSubscription<List<Order>>? activeOrdersStreamSubscription;
  StreamSubscription<List<Order>>? executedOrdersStreamSubscription;

  ActiveGameScreen({super.key});

  Future<void> _startSession(BuildContext context) async {
    activeOrdersStreamSubscription = (await Connection.sseActiveOrders(context.read<SessionProvider>().sessionId)).listen((orders) {
      print('SSE received orders: ${orders.length}');
      print('Order prices: ${orders.map((order) => order.price)}');

      // Get the provider without listening
      context.read<OrdersProvider>().setActiveOrders(orders);

      // Verify the update
      print(
          'Provider orders after update: ${context.read<OrdersProvider>().activeOrders.length}');
    }, onError: (error) => print('Active orders by price stream error: $error'));
    executedOrdersStreamSubscription = (await Connection.sseExecutedOrders(context.read<SessionProvider>().sessionId)).listen((orders) {
      context.read<OrdersProvider>().setExecutedOrders(orders);
    }, onError: (error) => print('Executed orders by price stream error: $error'));
  }

  @override
  Widget build(BuildContext context) {
    _startSession(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(screenPadding),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: TimerWidget(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Exchange',
                  style: GoogleFonts.geo().copyWith(fontSize: 35),
                ),
                const SizedBox(height: 16),
                LastMarketPriceWidget(),
                Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxDesktopWidth),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Active orders',
                                  style: GoogleFonts.geo().copyWith(fontSize: 20),
                                ),
                                const SizedBox(height: 16),
                                OrdersGraphWidget(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}