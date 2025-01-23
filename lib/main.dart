import 'package:provider/provider.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:trading_game_flutter/providers/orders_provider.dart';
import 'package:trading_game_flutter/providers/start_session_screen_color_provider.dart';
import 'package:trading_game_flutter/providers/user_info_provider.dart';
import 'package:trading_game_flutter/screens/active_game_screen.dart';
import 'package:trading_game_flutter/screens/main_screen.dart';
import 'package:trading_game_flutter/screens/player_dashboard_screen.dart';
import 'package:trading_game_flutter/screens/player_login_screen.dart';
import 'package:trading_game_flutter/screens/start_session_screen.dart';
import 'package:trading_game_flutter/screens/test_screen.dart';

import 'providers/session_provider.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // In development, you might want to use print
    // In production, you might want to use a proper logging backend
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SessionProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => StartSessionScreenColorProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserInfoProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => OrdersProvider(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashborad UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),
      onGenerateRoute: (settings) {
        final uri = Uri.base;
        if (uri.path.split('/')[1] == 'play') {
          final sessionId = uri.path.split('/')[2];
          return MaterialPageRoute(
            builder: (context) => PlayerLoginScreen(sessionId: sessionId),
          );
        }
        // Handle other routes here
        switch (uri.path) {
          case '/':
            return MaterialPageRoute(
                builder: (context) => StartSessionScreen());
          case '/main':
            return MaterialPageRoute(builder: (context) => MainScreen());
          case '/game':
            return MaterialPageRoute(builder: (context) => ActiveGameScreen());
          case '/test':
            return MaterialPageRoute(
                builder: (context) => AutoUpdateTestScreen());
          case '/game/active':
          default:
            return MaterialPageRoute(
              builder: (context) => MainScreen(),
            );
        }
      },
      routes: {
        '/player-dashboard': (context) => PlayerDashboardScreen(),
      },
    );
  }
}
