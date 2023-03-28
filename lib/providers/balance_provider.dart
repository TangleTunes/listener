import 'package:flutter/material.dart';

class BalanceProvider with ChangeNotifier {
  BigInt? _contractBalance;
  BigInt? _leger1Balance;

  BigInt? getContractBalance() {
    return _contractBalance;
  }

  void updateContractBalance(BigInt balance) {
    _contractBalance = balance;
    notifyListeners();
  }

  void setContractBalance(BigInt? balance) {
    _contractBalance = balance;
  }

  BigInt? getL1Balance() {
    return _leger1Balance;
  }

  void updateL1Balance(BigInt balance) {
    _leger1Balance = balance;
    notifyListeners();
  }

  void setL1Balance(BigInt? balance) {
    _leger1Balance = balance;
  }
}
