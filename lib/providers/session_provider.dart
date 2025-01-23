import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:trading_game_flutter/model/session_response_model.dart';
import 'package:trading_game_flutter/model/user_model.dart';

final _logger = Logger('SessionProvider');

class SessionProvider with ChangeNotifier {
  String? _sessionId;
  bool _sessionStarted = false;
  SessionResponse? _sessionResponse;
  List<User> _users = [];

  String get sessionId => _sessionId ?? '';
  bool get sessionStarted => _sessionStarted;
  SessionResponse? get sessionResponse => _sessionResponse;
  List<User> get users => _users;

  Future<void> setSessionId(String sessionId) async {
    _sessionId = sessionId;
    _sessionStarted = true;
    _logger.info("Session set: $_sessionId");
    notifyListeners();
  }

  void disableSession() {
    _sessionId = '';
    _sessionStarted = false;
    notifyListeners();
  }

  void updateSessionState(SessionResponse sessionResponse) {
    // Handle session state update if needed
    _sessionResponse = sessionResponse;
    notifyListeners();
  }

  void updateUsers(List<User> users) {
    _users = users;
    notifyListeners();
  }
}
