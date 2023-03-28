import 'package:flutter/material.dart';

class BalanceProvider with ChangeNotifier {
  BigInt? _contractBalance;
  BigInt? _leger2BalanceInWei;

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

  BigInt? getL2BalanceInWei() {
    return _leger2BalanceInWei;
  }

  void updateL2BalanceInWei(BigInt balance) {
    _leger2BalanceInWei = balance;
    notifyListeners();
  }

  void setL2BalanceInWei(BigInt? balance) {
    _leger2BalanceInWei = balance;
  }
}
