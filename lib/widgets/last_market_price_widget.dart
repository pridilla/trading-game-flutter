import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';

class LastMarketPriceWidget extends StatefulWidget {
  const LastMarketPriceWidget({super.key});

  @override
  State<LastMarketPriceWidget> createState() => _LastMarketPriceWidgetState();
}

class _LastMarketPriceWidgetState extends State<LastMarketPriceWidget> with TickerProviderStateMixin {

  int priceChange = 0;
  int lastPrice = 0;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    upperBound: 1.0,
    lowerBound: 0.5,
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {

    int newPrice = context.watch<OrdersProvider>().getLastPrice() ?? 0;
    if (newPrice != lastPrice) {
      priceChange = newPrice - lastPrice;
      lastPrice = newPrice;
      if (priceChange > 0) {
        _controller.forward();
      } else if (priceChange < 0) {
        _controller.reverse();
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Last Market Price',
              style: GoogleFonts.geo().copyWith(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$lastPrice$currencySymbol',
                    style: GoogleFonts.geo().copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 5),
                  RotationTransition(
                    turns: _animation,
                    child: Icon(
                      Icons.arrow_circle_up,
                      color: priceChange > 0 ? Colors.green : Colors.red,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}