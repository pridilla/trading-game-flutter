import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/providers/user_info_provider.dart';
import 'package:trading_game_flutter/util/responsive.dart';
import 'package:trading_game_flutter/widgets/depot_card_widget.dart';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  StreamSubscription<List<Order>>? _activeOrdersSubscription;

  @override
  void initState() {
    super.initState();
    _initializeSSEConnections();
  }

  void _initializeSSEConnections() async {
    final sessionId = context.read<SessionProvider>().sessionId;

    try {
      // Set up active orders by price stream
      final activeOrdersStream = await Connection.sseActiveOrders(sessionId);
      // Stream<List<Order>> activeOrdersStream = Stream.empty();
      _activeOrdersSubscription = activeOrdersStream.listen(
        (orders) {
          print('SSE received orders: ${orders.length}');
          print('Order prices: ${orders.map((order) => order.price)}');
          if (!mounted) return;

          // Get the provider without listening
          context.read<OrdersProvider>().setActiveOrders(orders);

          // Verify the update
          print(
              'Provider orders after update: ${context.read<OrdersProvider>().activeOrders.length}');
        },
        onError: (error) =>
            print('Active orders by price stream error: $error'),
      );
    } catch (e) {
      print('Error initializing SSE connections: $e');
    }
  }

  @override
  void dispose() {
    _activeOrdersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(screenPadding),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Dashboard',
                style: GoogleFonts.geo().copyWith(fontSize: 35),
              ),
              SizedBox(height: 16),
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxDesktopWidth/4),
                  child: DepotCardWidget(),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: OrdersColumnWidget(
                        tradeType: TradeType.buy,
                        title: 'Buy Orders',
                        buttonText: 'Add Buy Order',
                      ),
                    ),
                    Expanded(
                      child: OrdersColumnWidget(
                        tradeType: TradeType.sell,
                        title: 'Sell Orders',
                        buttonText: 'Add Sell Order',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersColumnWidget extends StatelessWidget {
  final TradeType tradeType;
  final String title;
  final String buttonText;
  final TextEditingController controller = TextEditingController();

  OrdersColumnWidget({
    super.key,
    required this.tradeType,
    required this.title,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserInfoProvider>().getUser()!.id;
    final activeOrders = context
        .watch<OrdersProvider>()
        .getUserOrders(userId)
        .where((order) => order.type == tradeType)
        .toList();

    print(
        'Active ${tradeType} orders for user $userId: ${activeOrders.length}');

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Responsive.isMobile(context) ? 200 : maxDesktopWidth,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                  Text(title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 200),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        hintText: 'Order price',
                        prefixIcon: Icon(Icons.sync),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (controller.text.isNotEmpty) {
                              Order order = Order(
                                type: tradeType,
                                userId: context
                                    .read<UserInfoProvider>()
                                    .getUser()!
                                    .id,
                                price: int.parse(controller.text),
                                createdAt: null,
                                executedAt: null,
                              );
                              await Connection.addOrder(
                                  context.read<SessionProvider>().sessionId,
                                  order);
                              controller.clear();
                            }
                          },
                          icon: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ),
                ] +
                activeOrders
                    .map((order) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: getOrderCard(order, context),
                        ))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget getOrderCard(Order order, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text('${order.price}€'),
            Spacer(),
            IconButton(
              onPressed: () async {
                await Connection.deleteOrder(
                    context.read<SessionProvider>().sessionId, order);
              },
              icon: Icon(Icons.highlight_remove),
            ),
          ],
        ),
      ),
    );
  }
}
