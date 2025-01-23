import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';

import 'package:trading_game_flutter/widgets/action_button_widget.dart';

class StartSessionButtonWidget extends StatelessWidget {
  const StartSessionButtonWidget({super.key});

  Future<void> _startSession(BuildContext context) async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final sessionResponse = await Connection.getNewSession();
    sessionProvider.setSessionId(sessionResponse.sessionId);
  }

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      onPressed: _startSession,
      buttonText: 'START SESSION',
      color: Colors.white,
      icon: Icons.rocket_launch,
    );
  }
}