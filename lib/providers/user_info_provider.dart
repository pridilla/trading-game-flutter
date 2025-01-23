import 'package:flutter/widgets.dart';
import 'package:trading_game_flutter/model/user_model.dart';

class UserInfoProvider extends ChangeNotifier {
  User? user;

  User? getUser() {
    return user;
  }

  void setUser(User user) {
    this.user = user;
    notifyListeners();
  }

  void removeUser() {
    this.user = null;
    notifyListeners();
  }

}