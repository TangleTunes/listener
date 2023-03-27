import 'package:flutter/material.dart';

class BalanceProvider with ChangeNotifier {
  BigInt? _balance;

  BigInt? getBalance() {
    return _balance;
  }

  void updateBalance(BigInt balance) {
    _balance = balance;
    notifyListeners();
  }

  void setBalance(BigInt? balance) {
    _balance = balance;
  }
}
