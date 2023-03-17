import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';

import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';

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
  @override
  String toString() {
    return "contractAddr: $contractAddr, rpcUrl: $rpcUrl,ownAddress: $ownAddress";
  }

  /// Public factory
  static Future<Either<MyError, SmartContract>> create(
      String rpcUrl,
      String contractAddress,
      int chainId,
      Credentials ownCredentials,
      String abiCode) async {
    // Call the private constructor
    SmartContract contract = SmartContract._create(
        rpcUrl, contractAddress, chainId, ownCredentials, abiCode);

    Either<MyError, int> potentialNonce = await contract.getNonce();
    if (potentialNonce.isRight) {
      contract.nonce = potentialNonce.right;
      return Right(contract);
    } else {
      return Left(potentialNonce.left);
    }
  }

  Future<Either<MyError, int>> getNonce() async {
    int myNonce = 0;
    Either<MyError, int> returnEither = Right(myNonce);
    try {
      myNonce = await client.getTransactionCount(ownAddress);
      returnEither = Right(myNonce);
    } on Exception catch (e) {
      return Left(MyError(
          key: AppError.DetermineNonceFailed,
          message: "Unable to determine the nonce",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> deposit(int amount) async {
    Either<MyError, Null> returnEither = Right(null);
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
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The deposit transaction failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> createUser(
      String name, String description) async {
    Either<MyError, Null> returnEither = Right(null);
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
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The create_user transaction failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> deleteUser() async {
    Either<MyError, Null> returnEither = Right(null);
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: contract,
              function: contract.function('delete_user'),
              parameters: []),
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The delete_user transaction failed",
          exception: e));
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> getChunks(
      Uint8List song, int index, int amount, String distributor) async {
    Either<MyError, Null> returnEither = Right(null);
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
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The get_chunks transaction failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> withdraw(int amount) async {
    Either<MyError, Null> returnEither = Right(null);
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
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The withdraw transaction failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> checkChunk(
      Uint8List song, int index, Uint8List chunk) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('check_chunk'),
          params: [song, index, chunk]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The check_chunk call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> chunksLength(Uint8List song) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('chunks_length'),
          params: [song]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The chunks_length call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> distributions(Uint8List song) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('distributions'),
          params: [song]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The distributions call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> genSongId(String name, String author) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('gen_song_id'),
          params: [name, EthereumAddress.fromHex(author)]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The gen_song_id call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> getRandDistributor(Uint8List song) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('get_rand_distributor'),
          params: [song]);
      if (outputList.length > 0) {
        returnEither = Right(outputList);
      } else {
        returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The get_rand_distributor call failed",
        ));
      }
    } on Exception catch (e) {
      print("Exception! $e and outputlist ${outputList[0]}");
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The get_rand_distributor call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> getSongs(BigInt index, BigInt amount) async {
    //TODO: add check wether song list is nonempty
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('get_songs'),
          params: [index, amount]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The get_songs call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> songList(int index) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('song_list'),
          params: [BigInt.from(index)]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The songs_list call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> songListLength() async {
    //TODO change to check if list is nonempty
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('song_list_length'),
          params: []);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The songs_list_length call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> users(String address) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('users'),
          params: [EthereumAddress.fromHex(address)]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The users call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, List>> songs(Uint8List song) async {
    List outputList = List.empty();
    Either<MyError, List> returnEither = Right(outputList);
    try {
      outputList = await client.call(
          contract: contract,
          function: contract.function('songs'),
          params: [song]);
      returnEither = Right(outputList);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The songs call failed",
          exception: e));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Uint8List>> createChunkGetTransaction(
      Uint8List song, int index, int amount, String distributor) async {
    Uint8List signedTx = Uint8List(0);
    Either<MyError, Uint8List> returnEither = Right(signedTx);
    try {
      print(
          "createChunkGetTransaction index $index amount $amount with nonce $nonce");
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
      signedTx =
          await client.signTransaction(ownCredentials, tx, chainId: chainId);
      returnEither = Right(signedTx);
    } on Exception catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractSignTransactionFailed,
          message: "Failed encoding and/or signing the get_chunks transaction",
          exception: e));
    }
    return returnEither;
  }
}
