import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toml/toml.dart';

import 'file_writer.dart';

const String scTomlFileName = "sc.toml";

Future<void> initilizeSmartContractIfNotSet() async {
  try {
    Map<String, dynamic> tomlMap = await readTomlFile();
    tomlMap["contract_address"];
    tomlMap["node_url"];
    tomlMap["chaid_id"];
  } catch (e) {
    ByteData smartContractSettingsByteData =
        await rootBundle.load('assets/SmartContract.toml');
    String tomlString =
        utf8.decode(smartContractSettingsByteData.buffer.asUint8List());
    await writeToFile(scTomlFileName, tomlString);
  }
}

Future<String> readAbiFromAssets() async {
  ByteData abiByteData = await rootBundle.load('assets/smartcontract.abi.json');
  String abiCode = utf8.decode(abiByteData.buffer.asUint8List());
  return abiCode;
}

Future<void> setContractAdress(String contractAdress) async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  tomlMap["contract_adress"] = contractAdress;
  await writeToTomlFile(tomlMap);
}

Future<String> readContractAdress() async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  return tomlMap["contract_address"];
}

Future<void> setNodeUrl(String nodeUrl) async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  tomlMap["node_url"] = nodeUrl;
  await writeToTomlFile(tomlMap);
}

Future<String> readNodeUrl() async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  return tomlMap["node_url"];
}

Future<void> setChainId(int chainId) async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  tomlMap["chain_id"] = chainId;
  await writeToTomlFile(tomlMap);
}

Future<int> readChainId() async {
  Map<String, dynamic> tomlMap = await readTomlFile();
  return tomlMap["chain_id"];
}

Future<Map<String, dynamic>> readTomlFile() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$scTomlFileName');
  final tomlString = file.readAsStringSync();
  Map<String, dynamic> tomlMap = TomlDocument.parse(tomlString).toMap();
  return tomlMap;
}

Future<void> writeToTomlFile(Map<String, dynamic> tomlMap) async {
  String tomlString = TomlDocument.fromMap(tomlMap).toString();

  await writeToFile(scTomlFileName, tomlString);
}
