import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading_game_flutter/connection/connection.dart';
import 'package:trading_game_flutter/const/constant.dart';
import 'package:trading_game_flutter/model/session_response_model.dart';
import 'package:trading_game_flutter/model/user_model.dart';
import 'package:trading_game_flutter/providers/user_info_provider.dart';
import 'package:trading_game_flutter/util/responsive.dart';
import 'package:trading_game_flutter/widgets/action_button_widget.dart';
import 'package:logging/logging.dart';

import '../providers/session_provider.dart';

class PlayerLoginScreen extends StatefulWidget {
  final String sessionId;

  const PlayerLoginScreen({super.key, required this.sessionId});

  @override
  State<PlayerLoginScreen> createState() => _PlayerLoginScreenState();
}

class _PlayerLoginScreenState extends State<PlayerLoginScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize session in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProvider = context.read<SessionProvider>();
      sessionProvider.setSessionId(widget.sessionId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayerLoginFieldWidget(sessionId: widget.sessionId),
    );
  }
}

class PlayerLoginFieldWidget extends StatefulWidget {
  final String sessionId;
  final maxTextFieldWidth = 400.0;

  const PlayerLoginFieldWidget({super.key, required this.sessionId});

  @override
  State<PlayerLoginFieldWidget> createState() => _PlayerLoginFieldWidgetState();
}

class _PlayerLoginFieldWidgetState extends State<PlayerLoginFieldWidget> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isTextFieldEnabled = true;
  final _logger = Logger('PlayerLoginFieldWidget');
  bool _isWaitingForGame = false;
  Timer? _timer;
  int _dotCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(screenPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxDesktopWidth),
          child: Center(
            child: _isWaitingForGame
                ? _buildWaitingAnimation()
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Get Ready to Play!',
                          style: GoogleFonts.geo().copyWith(
                            fontSize: Responsive.isMobile(context) ? 24 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxWidth: widget.maxTextFieldWidth),
                              child: TextFormField(
                                enabled: _isTextFieldEnabled,
                                focusNode: _focusNode,
                                onChanged: (value) {
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Enter your name',
                                  errorText:
                                      validate(_textEditingController.text),
                                ),
                                controller: _textEditingController,
                                validator: (value) => validate(value ?? ''),
                                onFieldSubmitted: (_) {
                                  if (_isTextFieldEnabled) {
                                    _handleLogin();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        buildLoginButton(context)
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingAnimation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Waiting for the game to start',
          style: GoogleFonts.geo().copyWith(
            fontSize: Responsive.isMobile(context) ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '.' * _dotCount,
          style: GoogleFonts.geo().copyWith(
            fontSize: Responsive.isMobile(context) ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String? validate(String input) {
    if (input.isEmpty) {
      return 'Your name is too short';
    }
    if (input.length > 32) {
      return 'Your name is too long';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isTextFieldEnabled = false;
      _isWaitingForGame = true;
    });

    try {
      final sessionId = context.read<SessionProvider>().sessionId;

      User user = await Connection.createUser(sessionId);
      User user2 = User(
          userId: user.userId,
          status: user.status,
          name: _textEditingController.text);
      await Connection.activateUser(sessionId, user2);

      if (!mounted) return;

      context.read<UserInfoProvider>().setUser(user2);
      _logger.info("User activated: ${user2.name}");

      Connection.sseSession(sessionId)
          .then((stream) => stream.listen((sessionState) {
                if (!mounted) return;
                if (sessionState.sessionState == SessionState.active) {
                  _logger.info("Session activated, navigating to dashboard");
                  Navigator.pushReplacementNamed(context, '/player-dashboard');
                }
              }, onError: (error) {
                _logger.severe("Error listening to session state: $error");
              }));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isTextFieldEnabled = true;
      });
      _logger.warning("Error during login: $e");
    }
  }

  Widget buildLoginButton(BuildContext context) {
    return ActionButtonWidget(
      onPressed: _isTextFieldEnabled
          ? (context) async => await _handleLogin()
          : (context) {
              return Future.value();
            },
      buttonText: 'ENTER GAME',
      color: Colors.white,
      icon: Icons.login,
    );
  }
}
