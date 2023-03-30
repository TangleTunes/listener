import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';

class SmartContractProvider with ChangeNotifier {
  SmartContract? _smartContract;

  SmartContract? getSmartContract() {
    return _smartContract;
  }

  void updateSmartContract(SmartContract contract) {
    _smartContract = contract;
    notifyListeners();
  }

  void setSmartContract(SmartContract? contract) {
    _smartContract = contract;
  }
}
