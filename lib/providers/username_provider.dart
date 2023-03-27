import 'package:flutter/material.dart';

class UsernameProvider with ChangeNotifier {
  String? _username = null;

  String? getUsername() {
    return _username;
  }

  void updateUsername(String? username) {
    _username = username;
    notifyListeners();
  }

  void setUsername(String? username) {
    _username = username;
  }
}
