
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/model/user_model.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/widgets/action_button_widget.dart';

class CreateUserButtonWidget extends StatelessWidget {
  const CreateUserButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonWidget(
      onPressed: (context) async {
        // print("Create User");
        User user = await Connection.createUser(context.read<SessionProvider>().sessionId);
        // print("User created: ${user.name}");
        User user2 = User(userId: user.userId, status: user.status, name: "some name");
        await Connection.activateUser(context.read<SessionProvider>().sessionId, user2);
        print("User activated: ${user2.name}");
      },
      buttonText: 'CREATE USER',
      color: Colors.white,
      icon: Icons.person_add,
    );
  }
}