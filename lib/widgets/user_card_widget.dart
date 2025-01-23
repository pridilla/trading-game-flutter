import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/model/user_model.dart';
import 'package:trading_game_flutter/providers/start_session_screen_color_provider.dart';
import 'package:trading_game_flutter/util/responsive.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.isMobile(context) ? 6 : 10,
          horizontal: Responsive.isMobile(context) ? 10 : 20,
        ),
        child: Text(
          user.name!,
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 14 : 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class UserCards extends StatelessWidget {
  final Stream<List<User>> userStream;
  const UserCards({required this.userStream, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: userStream,
      builder: (context, snapshot) {
        print('UserCards rebuild with ${snapshot.data} users');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              CircularProgressIndicator(
                color: context.watch<StartSessionScreenColorProvider>().color,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No users available');
        } else {
          final users = snapshot.data!;
          return Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            clipBehavior: Clip.antiAlias,
            children: users
                .where((user) => user.status == UserStatus.active)
                .toList()
                .map((user) => UserCard(user: user))
                .toList(),
          );
        }
      },
    );
  }
}
