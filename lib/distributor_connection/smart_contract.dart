import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';

import 'package:web3dart/web3dart.dart';

void main(List<String> args) async {
  String rpcUrl =
      "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
  EthereumAddress contractAddr =
      EthereumAddress.fromHex('0xb5F7F76bbdE176AC0A45EA1125F17784d8247aF4');
  // String privateKey = await loadPrivateKey();
  File file = File(
      '/Users/paul/Documents/UniversityOfTwente/Module11/Listener13/listener13/listener/lib/distributor_connection/smartcontract.abi.json');
  String content = await file.readAsString();
  SmartContract smartContract = SmartContract(
      rpcUrl,
      contractAddr,
      EthPrivateKey.fromHex("0xC5bE09A6296610a826CBDc75E86ea7A3B086Ae81"),
      content);

  var x = await smartContract.getSongs(0, 1);
  // print("x at 0 ${x[0][0][0]}");
  String s = hex.encode(x[0][0][0]);
  print('string s $s');
  Uint8List hexaaa = hexToBytes(
      "51dba6a00c006f51b012f6e6c1516675ee4146e03628e3567980ed1c354441f2");
  // print("hex $hex");

  print(await smartContract.getRandDistributor(x[0][0][0]));
  // print(await smartContract.songListLength());

  // print(await smartContract.getSongs(0, 1));
}

class SmartContract {
  final String rpcUrl;
  final EthereumAddress contractAddr;
  String abiCode;
  late Web3Client client;
  late Credentials ownCredentials;
  late EthereumAddress ownAddress;
  late DeployedContract contract;

  SmartContract(
      this.rpcUrl, this.contractAddr, this.ownCredentials, this.abiCode) {
    client = Web3Client(rpcUrl, http.Client());
    ownAddress = ownCredentials.address;
    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'TangleTunes'), contractAddr);
  }

  void deposit(int amount) async {
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
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
          ownCredentials,
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
        ownCredentials,
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
          ownCredentials,
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
          ownCredentials,
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
          params: [BigInt.from(index)]);
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

  Future<Uint8List> createChunkGetTransaction(Uint8List song, int index,
      int amount, String distributor, int nonce) async {
    print("createChunkGetTransaction with nonce $nonce");
    // client.signTransaction(credentials, )
    Uint8List data = contract.function('get_chunks').encodeCall([
      song,
      BigInt.from(index),
      BigInt.from(amount),
      EthereumAddress.fromHex(distributor)
    ]);

    Transaction tx = Transaction(
        from: ownAddress,
        to: contractAddr,
        gasPrice: EtherAmount.inWei(BigInt.from(1)),
        maxGas: 300000,
        data: data,
        nonce: nonce);

    Uint8List signedTx =
        await client.signTransaction(ownCredentials, tx, chainId: 1074);

    return signedTx;
  }
}
