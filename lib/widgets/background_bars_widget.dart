import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/start_session_screen_color_provider.dart';

class BackgroundBarsWidget extends StatefulWidget {
  const BackgroundBarsWidget({super.key});

  @override
  BackgroundBarsWidgetState createState() => BackgroundBarsWidgetState();
}

class BackgroundBarsWidgetState extends State<BackgroundBarsWidget> with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final int numBars = 10;
  List<double> _oldBars = [];
  List<double> _bars = List.generate(10, (_) => 0.0);

  @override
  void initState() {
    super.initState();
    generateBars();
  }

  void generateBars() {
    _oldBars = _bars;
    setState(() {
      _bars = List.generate(10, (_) => _random.nextDouble() * 200);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StartSessionScreenColorProvider colorProvider = context.read<StartSessionScreenColorProvider>();
    if (mounted) {
      colorProvider = context.watch<StartSessionScreenColorProvider>();
    }
    Color color = colorProvider.color;
    double animationValue = colorProvider.animationValue;
    return Positioned.fill(
        child: CustomPaint(
          painter: _BarsPainter(_bars, _oldBars, color, animationValue),
        ),
      );
  }
}

class _BarsPainter extends CustomPainter {
  final List<double> bars;
  final List<double> oldBars;
  final Color color;
  final double animationValue;

  final double _barToEmptySpaceRatio = 0.7;

  _BarsPainter(this.bars, this.oldBars, this.color, double animationValue)
      : animationValue = Curves.easeInOut.transform(animationValue);


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
      paint.color = color;

    final barWidth = size.width * _barToEmptySpaceRatio / bars.length;
    for (int i = 0; i < bars.length; i++) {
      final barHeight = bars[i];
      final oldBarHeight = oldBars[i];
      final x = i * size.width / bars.length;
      final animatedHeight = barHeight * (animationValue) + oldBarHeight * (1 - animationValue);
      final y = size.height - animatedHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, animatedHeight),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double convertLinearToEaseOutQuadratic(double t) {
    return t * t;
  }
}