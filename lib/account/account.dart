import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

Credentials createAccount(
    String username, String password, SmartContract smartContract) {
  EthPrivateKey credentials = EthPrivateKey.createRandom(Random.secure());
  setPrivateKey(utf8.decode(credentials.privateKey), password);
  smartContract.createUser(username, "Descriptionless");
  return credentials;
}

void setPrivateKey(String privateKey, String password) async {
  EthPrivateKey ethPrivateKey =
      EthPrivateKey(Uint8List.fromList(utf8.encode(privateKey)));
  Wallet wallet = Wallet.createNew(ethPrivateKey, password, Random());
  String v3walletEncrypted = wallet.toJson();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pk.json');
  if (await file.exists()) {
    file.create();
  }
  final data = {'privatekey': v3walletEncrypted};
  await file.writeAsString(jsonEncode(data));
}

Future<String> unlockPrivateKey(String password) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pk.json');
  String contents = await file.readAsString();
  final decodedJson = jsonDecode(contents);
  String encoded = decodedJson['privatekey'];
  Wallet wallet = Wallet.fromJson(encoded, password);
  Uint8List pk = wallet.privateKey.privateKey;
  String privateKey = utf8.decode(pk);
  return privateKey;
}
