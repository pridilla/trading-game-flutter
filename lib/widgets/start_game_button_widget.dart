import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/screens/active_game_screen.dart';
import 'package:trading_game_flutter/widgets/action_button_widget.dart';

class StartGameButtonWidget extends StatelessWidget {
  const StartGameButtonWidget({super.key});

  Future<void> _startGame(BuildContext context) async {
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    final sessionId = sessionProvider.sessionId;
    await Connection.startGame(sessionId);

    //navigate to a new screen with the active game
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ActiveGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    return ActionButtonWidget(
      onPressed: _startGame,
      buttonText: 'START GAME',
      color: color, // You can customize the color as needed
      icon: Icons.play_arrow,
    );
  }
}
