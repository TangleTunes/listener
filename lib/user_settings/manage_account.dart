import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:either_dart/either.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';
import 'file_writer.dart';

Credentials createAccount(
    String username, String password, SmartContract smartContract) {
  EthPrivateKey credentials = EthPrivateKey.createRandom(Random.secure());
  setPrivateKey(utf8.decode(credentials.privateKey), password);
  smartContract.createUser(username, "Descriptionless");
  return credentials;
}

Future<void> setPrivateKey(String privateKey, String password) async {
  EthPrivateKey ethPrivateKey =
      EthPrivateKey(Uint8List.fromList(utf8.encode(privateKey)));
  Wallet wallet = Wallet.createNew(ethPrivateKey, password, Random.secure());
  String v3walletEncrypted = wallet.toJson();
  final data = {'privatekey': v3walletEncrypted};
  await writeToFile("pk.json", jsonEncode(data));
}

Future<Either<MyError, String>> unlockPrivateKey(String password) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pk.json');
  String contents = await file.readAsString();
  final decodedJson = json.decode(contents);
  String encoded = decodedJson['privatekey'];
  try {
    Wallet wallet = Wallet.fromJson(encoded, password);
    Uint8List pk = wallet.privateKey.privateKey;
    String privateKey = utf8.decode(pk);
    return Right(privateKey);
  } on ArgumentError catch (e) {
    return Left(MyError(
        key: AppError.IncorrectPrivateKeyPassword,
        message: "Incorrect password."));
  }
}

Future<bool> alreadyCoupled() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/pk.json');
    String contents = await file.readAsString();
    return jsonDecode(contents)['privatekey'] != null; //FIXME? json.decode
  } catch (e) {
    return false;
  }
}
