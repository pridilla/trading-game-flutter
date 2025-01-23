import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/model/session_response_model.dart';
import 'package:trading_game_flutter/model/user_model.dart';
import 'package:trading_game_flutter/providers/session_provider.dart';
import 'package:trading_game_flutter/widgets/background_bars_widget.dart';
import 'package:trading_game_flutter/widgets/session_connection_info_widget.dart';
import 'package:trading_game_flutter/widgets/start_game_button_widget.dart';
import 'package:trading_game_flutter/widgets/start_session_button_widget.dart';
import 'package:trading_game_flutter/util/responsive.dart';
import 'package:trading_game_flutter/widgets/user_card_widget.dart';

import '../providers/start_session_screen_color_provider.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<BackgroundBarsWidgetState> _backgroundBarsKey =
      GlobalKey<BackgroundBarsWidgetState>();
  final List<Color> _colors = [primaryColor, secondaryColor, selectionColor];
  final Random _random = Random();
  late AnimationController _controller;

  Color _oldColor = Colors.white;
  Color _color = Colors.blue;

  Stream<List<User>>? _createdUsersStream;
  StreamSubscription<List<User>>? _createdUsersSubscription;
  StreamSubscription<SessionResponse>? _sessionStateSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        if (mounted) {
          StartSessionScreenColorProvider colorProvider =
              context.read<StartSessionScreenColorProvider>();
          Color animatedColor =
              Color.lerp(_oldColor, _color, _controller.value)!;
          colorProvider.setColorAndAnimation(animatedColor, _controller.value);
        }
      });
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        updateColor();
        _backgroundBarsKey.currentState!.generateBars();
      }
    });
    Timer(Duration(seconds: 1), () {
      _controller.forward(from: 0);
    });

    // Initialize SSE connections if session is already started
    final sessionProvider = context.read<SessionProvider>();
    if (sessionProvider.sessionStarted) {
      _initializeSSEConnections(sessionProvider.sessionId);
    }

    // Add listener for session changes
    sessionProvider.addListener(() {
      if (sessionProvider.sessionStarted && _createdUsersStream == null) {
        _initializeSSEConnections(sessionProvider.sessionId);
      }
    });
  }

  void _initializeSSEConnections(String sessionId) async {
    try {
      // Set up created users stream and convert it to broadcast stream immediately
      _createdUsersStream =
          (await Connection.sseTest(sessionId)).asBroadcastStream();
      _createdUsersSubscription = _createdUsersStream?.listen(
        (users) {
          setState(() {}); // Trigger rebuild if needed
        },
        onError: (error) => print('Created users stream error: $error'),
      );

      // Set up session state stream
      final sessionStateStream = await Connection.sseSession(sessionId);
      _sessionStateSubscription = sessionStateStream.listen(
        (sessionResponse) =>
            context.read<SessionProvider>().updateSessionState(sessionResponse),
        onError: (error) => print('Session state stream error: $error'),
      );
    } catch (e) {
      print('Error initializing SSE connections: $e');
    }
  }

  @override
  void dispose() {
    _createdUsersSubscription?.cancel();
    _sessionStateSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void updateColor() {
    _oldColor = _color;
    _color = _colors[_random.nextInt(_colors.length)];
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    bool sessionStarted = context.watch<SessionProvider>().sessionStarted;
    return Center(
      child: Scaffold(
        body: Stack(
          children: [
            BackgroundBarsWidget(key: _backgroundBarsKey),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxDesktopWidth),
                  child: sessionStarted
                      ? getWaitingRoom()
                      : getStartSessionButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getStartSessionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome to the Trading Game',
          style: GoogleFonts.geo().copyWith(
            fontSize: Responsive.isMobile(context) ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: context.read<StartSessionScreenColorProvider>().color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Press the button below to start a new session',
          style: TextStyle(
            fontSize: Responsive.isMobile(context) ? 16 : 20,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        StartSessionButtonWidget(),
      ],
    );
  }

  Widget getWaitingRoom() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Waiting Room',
          style: GoogleFonts.geo().copyWith(
            fontSize: Responsive.isMobile(context) ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: context.read<StartSessionScreenColorProvider>().color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: UserCards(
                      userStream: _createdUsersStream ?? Stream.empty()),
                ),
              ),
              SizedBox(width: 16),
              SessionConnectionInfoWidget()
            ],
          ),
        ),
        SizedBox(height: 32),
        // CreateUserButtonWidget(),
        // SizedBox(height: 16),
        StartGameButtonWidget(),
      ],
    );
  }
}
