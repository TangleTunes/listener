import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';

class CredentialsProvider with ChangeNotifier {
  late Credentials _credentials;

  Credentials getCredentials() {
    return _credentials;
  }

  void updateOwnCredentials(String privateKey) {
    _credentials = EthPrivateKey.fromHex(privateKey);
    notifyListeners();
  }

  void setOwnCredentials(String privateKey) {
    _credentials = EthPrivateKey.fromHex(privateKey);
  }
}
