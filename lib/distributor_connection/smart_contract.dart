import 'dart:convert';
import 'dart:typed_data';
// import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

//import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

void main(List<String> args) async {
  String rpcUrl =
      "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
  EthereumAddress contractAddr =
      EthereumAddress.fromHex('0x8fA1fc1Eec824a36fD31497EAa8716Fc9C446d51');
  String privateKey = await loadPrivateKey();
  SmartContract smartContract = SmartContract(
      rpcUrl, contractAddr, privateKey, 'assets/smartcontract.abi.json');
  await smartContract.init(rpcUrl, privateKey);
  //smartContract.createUser("paul", "paul");
  //smartContract.deposit(1);
  //smartContract.deleteUser();

  // print(await smartContract.users(smartContract.ownAddress.toString()));
}

Future<String> loadPrivateKey() async {
  ByteData pk = await rootBundle.load("assets/privatekey.json");
  String loadJson = utf8.decode(pk.buffer.asUint8List());
  final decodedJson = jsonDecode(loadJson);
  String privateKey = decodedJson['privatekey'];
  return privateKey;
  // return "xxx";
}

class SmartContract {
  final String rpcUrl;
  final String privateKey;
  final EthereumAddress contractAddr;
  String abiCode;
  late Web3Client client;
  late Credentials credentials;
  late EthereumAddress ownAddress;
  late DeployedContract contract;

  Future init(String rpcUrl, String privateKey) async {
    client = Web3Client(rpcUrl, http.Client());
    credentials = EthPrivateKey.fromHex(privateKey);
    ownAddress = credentials.address;
    // abiCode = await abiFile.readAsString();
    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'TangleTunes'), contractAddr);
  }

  SmartContract(this.rpcUrl, this.contractAddr, this.privateKey, this.abiCode);

  void deposit(int amount) async {
    try {
      String tx_hash = await client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('deposit'),
              parameters: [],
              value: EtherAmount.fromInt(EtherUnit.ether, amount)),
          chainId: 1074);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  void createUser(String name, String description) async {
    try {
      String tx_hash = await client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('create_user'),
              parameters: [name, description]),
          chainId: 1074);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  void deleteUser() async {
    String tx_hash = await client.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract,
            function: contract.function('delete_user'),
            parameters: []),
        chainId: 1074);
    TransactionReceipt? tx_receipt =
        await client.getTransactionReceipt(tx_hash);
  }

  void getChunks(
      Uint8List song, int index, int amount, String distributor) async {
    try {
      String tx_hash = await client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('get_chunks'),
              parameters: [
                song,
                index,
                amount,
                EthereumAddress.fromHex(distributor)
              ]),
          chainId: 1074);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  void withdraw(int amount) async {
    try {
      String tx_hash = await client.sendTransaction(
          credentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('withdraw'),
              parameters: [amount]),
          chainId: 1074);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  Future<List> checkChunk(Uint8List song, int index, Uint8List chunk) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('check_chunk'),
          params: [song, index, chunk]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> chunksLength(Uint8List song) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('chunks_length'),
          params: [song]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> distributions(Uint8List song) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('distributions'),
          params: [song]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> genSongId(String name, String author) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('gen_song_id'),
          params: [name, EthereumAddress.fromHex(author)]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> getRandDistributor(Uint8List song) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('get_rand_distributor'),
          params: [song]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> getSongs(int index, int amount) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('get_songs'),
          params: [BigInt.from(index), BigInt.from(amount)]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> songList(int index) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('song_list'),
          params: [index]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> songListLength() async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('song_list_length'),
          params: []);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> users(String address) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('users'),
          params: [EthereumAddress.fromHex(address)]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<List> songs(Uint8List song) async {
    List outputList = List.empty();
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('songs'),
          params: [song]);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
    return outputList;
  }

  Future<Uint8List> createChunkGetTransaction(
      Uint8List song, int index, int amount, String distributor) async {
    // client.signTransaction(credentials, )
    print("Distributor address: $distributor");
    Uint8List data = contract.function('get_chunks').encodeCall([
      song,
      BigInt.from(index),
      BigInt.from(amount),
      EthereumAddress.fromHex(distributor)
    ]);

    var tx = Transaction(
        from: ownAddress,
        to: contractAddr,
        gasPrice: EtherAmount.inWei(BigInt.from(1)),
        maxGas: 100000,
        data: data);

    var signed_tx =
        await client.signTransaction(credentials, tx, chainId: 1074);

    // var response = await client.sendRawTransaction(signed_tx);
    // print('response: $response');

    return signed_tx;
  }
}