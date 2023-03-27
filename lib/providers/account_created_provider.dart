import 'package:flutter/material.dart';

class AccountCreatedProvider with ChangeNotifier {
  bool _accountCreated = false;

  bool getAccountCreated() {
    return _accountCreated;
  }

  void updateAccountCreated(bool accountCreated) {
    _accountCreated = accountCreated;
    notifyListeners();
  }

  void setAccountCreated(bool accountCreated) {
    _accountCreated = accountCreated;
  }
}
