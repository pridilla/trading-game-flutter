import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/model/order_model.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';

class OrdersGraphWidget extends StatelessWidget {
  const OrdersGraphWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Buy Orders", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 40),
              Text("Sell Orders",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        SizedBox(height: 16),
        Consumer<OrdersProvider>(
          builder: (context, dataProvider, child) {
            final orders = dataProvider.getOrdersByPrice();
            if (orders.isEmpty) {
              return Center(child: Text("No data available"));
            }

            final quantities = (orders.values.map((v) => v.length).toList() +
                orders.values.map((v) => v.length).toList());
            quantities.sort();
            final maxQuantity = quantities.last;
            var sortedOrdersByPrice = orders.entries.toList();
            sortedOrdersByPrice.sort((a, b) => a.key.compareTo(b.key));

            return Column(
              children: sortedOrdersByPrice.toList().map((entry) {
                final quantity = entry.value.length;
                final firstOrder = entry.value.first;
                final widthFactor = quantity / maxQuantity;
                final buyWidthFactor =
                    firstOrder.type == TradeType.buy ? widthFactor : 0.0;
                final sellWidthFactor =
                    firstOrder.type == TradeType.sell ? widthFactor : 0.0;

                return Row(
                  children: [
                    OrderGraphForTradeTypeWidget(
                        order: firstOrder,
                        tradeType: TradeType.buy,
                        quantity: quantity,
                        widthFactor: buyWidthFactor,
                        color: primaryColor),
                    const SizedBox(width: 8),
                    Text("${firstOrder.price}€"),
                    const SizedBox(width: 8),
                    OrderGraphForTradeTypeWidget(
                        order: firstOrder,
                        tradeType: TradeType.sell,
                        quantity: quantity,
                        widthFactor: sellWidthFactor,
                        color: secondaryColor),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class OrderGraphForTradeTypeWidget extends StatefulWidget {
  final Order order;
  final TradeType tradeType;
  final int quantity;
  final double widthFactor;
  final Color color;

  final _animationDuration = const Duration(milliseconds: 200);

  const OrderGraphForTradeTypeWidget(
      {super.key,
      required this.order,
      required this.tradeType,
      required this.quantity,
      required this.widthFactor,
      required this.color});

  @override
  State<OrderGraphForTradeTypeWidget> createState() =>
      _OrderGraphForTradeTypeWidgetState();
}

class _OrderGraphForTradeTypeWidgetState
    extends State<OrderGraphForTradeTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        return Row(
          children: [
            if (widget.tradeType == TradeType.buy)
              AnimatedContainer(
                duration: widget._animationDuration,
                width: (1 - widget.widthFactor) * constraints.maxWidth,
                height: 20,
                color: Colors.transparent,
              ),
            AnimatedContainer(
              duration: widget._animationDuration,
              width: widget.widthFactor * constraints.maxWidth,
              height: 20,
              color: widget.color,
              child: widget.tradeType == widget.order.type
                  ? Center(
                      child: Align(
                        alignment: widget.tradeType == TradeType.sell
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            widget.quantity.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            if (widget.tradeType == TradeType.sell)
              AnimatedContainer(
                duration: widget._animationDuration,
                width: (1 - widget.widthFactor) * constraints.maxWidth,
                height: 20,
                color: Colors.transparent,
              ),
          ],
        );
      }),
    );
  }
}
