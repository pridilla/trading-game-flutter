import 'package:flutter/material.dart';
import 'package:trading_game_flutter/util/responsive.dart';

class ActionButtonWidget extends StatelessWidget {
  final Future<void> Function(BuildContext) onPressed;
  final String buttonText;
  final Color color;
  final IconData icon;

  const ActionButtonWidget({
    required this.onPressed,
    required this.buttonText,
    required this.color,
    required this.icon,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await onPressed(context);
        },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.isMobile(context) ? 12 : 20,
          horizontal: Responsive.isMobile(context) ? 20 : 40,
        ),
        textStyle: TextStyle(
          fontSize: Responsive.isMobile(context) ? 14 : 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        icon,
        color: color,
      ),
      label: Text(
        buttonText,
        style: TextStyle(
          color: color
        ),
      ),
    );
  }
}