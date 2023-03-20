import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';
import '../error_handling/app_error.dart';
import "package:convert/src/hex.dart";

class CredentialsProvider with ChangeNotifier {
  EthPrivateKey? _credentials;

  EthPrivateKey? getCredentials() {
    return _credentials;
  }

  void updateOwnCredentials(String privateKey) {
    _credentials = EthPrivateKey.fromHex(privateKey);
    notifyListeners();
  }

  Either<MyError, Null> setOwnCredentials(String privateKey) {
    try {
      _credentials = EthPrivateKey.fromHex(privateKey);
      return Right(null);
    } catch (e) {
      return Left(MyError(
          key: AppError.InvalidPrivateKey,
          message: "Invalid private key format"));
    }
  }
}
