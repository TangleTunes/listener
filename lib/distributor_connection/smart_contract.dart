import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';

import 'package:web3dart/web3dart.dart';

class SmartContract {
  final String rpcUrl;
  late EthereumAddress contractAddr;
  String abiCode;
  late Web3Client client;
  late Credentials ownCredentials;
  late EthereumAddress ownAddress;
  late DeployedContract contract;
  int chainId;
  late int nonce;
  SmartContract._create(this.rpcUrl, String contractAddress, this.chainId,
      this.ownCredentials, this.abiCode) {
    // Do most of your initialization here, that's what a constructor is for
    contractAddr = EthereumAddress.fromHex(contractAddress);
    client = Web3Client(rpcUrl, http.Client());
    ownAddress = ownCredentials.address;
    contract = DeployedContract(
        ContractAbi.fromJson(abiCode, 'TangleTunes'), contractAddr);
  }

  /// Public factory
  static Future<SmartContract> create(String rpcUrl, String contractAddress,
      int chainId, Credentials ownCredentials, String abiCode) async {
    // Call the private constructor
    var thisObj = SmartContract._create(
        rpcUrl, contractAddress, chainId, ownCredentials, abiCode);

    // Do initialization that requires async
    thisObj.nonce =
        await thisObj.client.getTransactionCount(thisObj.ownAddress);

    // Return the fully initialized object
    return thisObj;
  }

  Future<void> deposit(int amount) async {
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('deposit'),
              parameters: [],
              value: EtherAmount.fromInt(EtherUnit.ether, amount)),
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  Future<void> createUser(String name, String description) async {
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('create_user'),
              parameters: [name, description]),
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  Future<void> deleteUser() async {
    String tx_hash = await client.sendTransaction(
        ownCredentials,
        Transaction.callContract(
            contract: contract,
            function: contract.function('delete_user'),
            parameters: []),
        chainId: chainId);
    TransactionReceipt? tx_receipt =
        await client.getTransactionReceipt(tx_hash);
  }

  Future<void> getChunks(
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
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
    } finally {
      await client.dispose();
    }
  }

  Future<void> withdraw(int amount) async {
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('withdraw'),
              parameters: [amount]),
          chainId: chainId);
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

  Future<Uint8List> createChunkGetTransaction(
      Uint8List song, int index, int amount, String distributor) async {
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
    nonce++; //Increment nonce after creating the transaction
    Uint8List signedTx =
        await client.signTransaction(ownCredentials, tx, chainId: chainId);
    return signedTx;
  }
}
