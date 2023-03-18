import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:either_dart/either.dart';
import 'package:flutter/widgets.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import '../error_handling/app_error.dart';
import '../providers/credentials_provider.dart';
import 'file_writer.dart';

Credentials createAccount(
    String username, String password, BuildContext context) {
  EthPrivateKey credentials = EthPrivateKey.createRandom(Random.secure());
  setPrivateKey(hex.encode(credentials.privateKey), password, context);
  return credentials;
}

Future<void> setPrivateKey(
    String privateKey, String password, BuildContext context) async {
  EthPrivateKey ethPrivateKey = EthPrivateKey.fromHex(privateKey);
  Wallet wallet = Wallet.createNew(ethPrivateKey, password, Random.secure());
  String v3walletEncrypted = wallet.toJson();
  final data = {'privatekey': v3walletEncrypted};
  await writeToFile("pk.json", jsonEncode(data));
  context.read<CredentialsProvider>().updateOwnCredentials(privateKey);
}

Future<Either<MyError, String>> unlockPrivateKey(String password) async {
  final directory = await getApplicationDocumentsDirectory();
  try {
    final file = File('${directory.path}/pk.json');
    String contents = await file.readAsString();
    final decodedJson = json.decode(contents);
    String encoded = decodedJson['privatekey'];
    try {
      Wallet wallet = Wallet.fromJson(encoded, password);
      Uint8List pk = wallet.privateKey.privateKey;
      String privateKey = hex.encode(pk);
      print("uuu read from file ${privateKey}");
      return Right(privateKey);
    } on ArgumentError catch (e) {
      return Left(MyError(
          key: AppError.IncorrectPrivateKeyPassword,
          message: "Incorrect password."));
    }
  } on Exception catch (e) {
    return Left(MyError(
        key: AppError.NonexistetOrCorruptedPrivateKeyFile,
        message: "No private key stored on device"));
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
