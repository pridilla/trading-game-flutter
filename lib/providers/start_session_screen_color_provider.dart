import 'package:flutter/material.dart';

class StartSessionScreenColorProvider with ChangeNotifier {
  Color _color = Colors.white;
  double _animationValue = 0.0;

  Color get color => _color;
  double get animationValue => _animationValue;

  void setColorAndAnimation(Color color, double value) {
    _animationValue = value;
    _color = color;
    notifyListeners();
  }

  void startSession() {
    notifyListeners();
  }

}