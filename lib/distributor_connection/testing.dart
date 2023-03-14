import 'dart:io';
import 'package:toml/toml.dart';

// void main() async {
// DistributorContact d = DistributorContact(
//     "0800000722040506080000072204050608000007220405060800000722040506");
// await d.initialize();
// DistributorContact d2 = DistributorContact(
//     "0800000722040506080000072204050608000007220405060800000722040506");
// await d2.initialize();
// print("initialized");
// List<Uint8List> song = [];
// // for (int i = 0; i < 20; i++) {
// //   Uint8List returnedChunk = await d.requestChunk(i);
// //   song.add(returnedChunk);
// //   print("recieved chunk $i");
// // }
// Uint8List returnedChunk = await d.giveMeChunk(0);
// Uint8List returnedChunk1 = await d.giveMeChunk(1);

// print("Song decoding finished ");
// String rpcUrl =
//     "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
// EthereumAddress contractAddr =
//     EthereumAddress.fromHex('0x8fA1fc1Eec824a36fD31497EAa8716Fc9C446d51');
// String loadJson =
//     await File('lib/distributor_connection/privatekey.json').readAsString();
// final decodedJson = jsonDecode(loadJson);
// String privateKey = decodedJson['privatekey'];
// String abiCode =
//     await File('lib/distributor_connection/smartcontract.abi.json')
//         .readAsString();
// SmartContract smartContract = SmartContract(
//     rpcUrl, contractAddr, await createAccount("x", "xx"), abiCode);
// var songList = await smartContract.songList(0);
// print(songList.toString());
// String songId = hex.encode(songList[0] as List<int>);
// print("songId $songId");
// var song1Info = await smartContract.songs(Uint8List.fromList(songList[0]));
// var song1Size = song1Info[4];
// print("song1Info $song1Info");
// print("song1Size $song1Size");
// }

void main(List<String> args) async {
  final file = File('lib/distributor_connection/SmartContract.toml');
  final tomlString = file.readAsStringSync();
  Map<String, dynamic> tomlMap = TomlDocument.parse(tomlString).toMap();
  print(tomlMap["contract_address"]);
  tomlMap["myman"] = "yes";
  // String rpcUrl =
  //     "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
  // EthereumAddress contractAddr =
  //     EthereumAddress.fromHex('0xb5F7F76bbdE176AC0A45EA1125F17784d8247aF4');
  // // String privateKey = await loadPrivateKey();
  // File file = File(
  //     '/Users/paul/Documents/UniversityOfTwente/Module11/Listener13/listener13/listener/lib/distributor_connection/smartcontract.abi.json');
  // String content = await file.readAsString();
  // SmartContract smartContract = SmartContract(rpcUrl, contractAddr,
  //     EthPrivateKey.fromHex("fillprivatekeyhere"), content);

  // var x = await smartContract.getSongs(0, 1);
  // // print("x at 0 ${x[0][0][0]}");
  // String s = hex.encode(x[0][0][0]);
  // print('string s $s');
  // Uint8List hexaaa = hexToBytes(
  //     "51dba6a00c006f51b012f6e6c1516675ee4146e03628e3567980ed1c354441f2");
  // // print("hex $hex");

  // print(await smartContract.getRandDistributor(x[0][0][0]));
  // print(await smartContract.songListLength());

  // print(await smartContract.getSongs(0, 1));
}
