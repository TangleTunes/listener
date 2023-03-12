import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:cryptography/cryptography.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';

import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

Credentials createAccount(
    String username, String password, SmartContract smartContract) {
  EthPrivateKey credentials = EthPrivateKey.createRandom(Random.secure());
  String privateKey = base64.encode(credentials.privateKey);
  print("read pk as $privateKey");
  setPrivateKey(privateKey, password);
  smartContract.createUser(username, "Descriptionless");
  return credentials;
}

void coupleAccount(String privateKey, String password) {
  setPrivateKey(privateKey, password);
}

void setPrivateKey(String privateKey, String password) async {
  final key = await keyFromPassword(password);
  final iv = IV.fromLength(16);
  Encrypter encrypter = Encrypter(AES(key));
  Encrypted encrypted = encrypter.encrypt(privateKey, iv: iv);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pk.json');
  if (await file.exists()) {
    file.create();
  }
  final data = {'privatekey': encrypted.base64};
  await file.writeAsString(jsonEncode(data));
}

Future<String> unlockPrivateKey(String password) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pk.json');
  String contents = await file.readAsString();
  final decodedJson = jsonDecode(contents);
  String pkHash = decodedJson['privatekey'];
  final key = await keyFromPassword(password);

  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));
  final decrypted = encrypter.decrypt(Encrypted.from64(pkHash), iv: iv);
  return decrypted;
}

Future<Key> keyFromPassword(String password) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 10000, // 20k iterations
    bits: 256, // 256 bits = 32 bytes output
  );

  // Calculate a hash that can be stored in the database
  final newSecretKey = await pbkdf2.deriveKeyFromPassword(
    // Password given by the user.
    password: password,

    // Nonce (also known as "salt") should be some random sequence of
    // bytes.
    //
    // You should have a different nonce for each user in the system
    // (which you store in the database along with the hash).
    // If you can't do that for some reason, choose a random value not
    // used by other applications.
    nonce: const [1, 2, 3],
  );

  List<int> secretKeyBytes = await newSecretKey.extractBytes();
  return Key(Uint8List.fromList(secretKeyBytes));
}
