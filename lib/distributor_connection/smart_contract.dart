import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';
import '../user_settings/manage_smart_contract_details.dart';

class SmartContract {
  final String rpcUrl;
  late EthereumAddress contractAddr;
  late String abiCode;
  late Web3Client client;
  late Credentials ownCredentials;
  late EthereumAddress ownAddress;
  late DeployedContract deployedContract;
  int chainId;
  late int nonce;

  SmartContract._create(
      this.rpcUrl, String contractAddress, this.chainId, this.ownCredentials) {
    // Do most of your initialization here, that's what a constructor is for

    client = Web3Client(rpcUrl, http.Client());
    ownAddress = ownCredentials.address;
  }
  @override
  String toString() {
    return "contractAddr: $contractAddr, rpcUrl: $rpcUrl,ownAddress: $ownAddress";
  }

  BigInt generateRandom256BitNumber() {
    final random = Random.secure();
    final List<int> bytes = List.generate(32, (_) => random.nextInt(256));
    final BigInt result = BigInt.parse(
        bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);
    return result;
  }

  /// Public factory
  static Future<Either<MyError, SmartContract>> create(String rpcUrl,
      String contractAddress, int chainId, Credentials ownCredentials) async {
    // Call the private constructor
    SmartContract contract =
        SmartContract._create(rpcUrl, contractAddress, chainId, ownCredentials);
    try {
      contract.contractAddr = EthereumAddress.fromHex(contractAddress);
    } on ArgumentError catch (e) {
      return Left(MyError(
        key: AppError.SmartContractCreateFailed,
        message: "Invalid hex",
      ));
    }
    contract.abiCode = await readAbiFromAssets();
    contract.deployedContract = DeployedContract(
        ContractAbi.fromJson(contract.abiCode, 'TangleTunes'),
        contract.contractAddr);
    Either<MyError, Null> potentialNonce = await contract.updateNonce();
    if (potentialNonce.isRight) {
      return Right(contract);
    } else {
      return Left(potentialNonce.left);
    }
  }

  Future<Either<MyError, Null>> updateNonce() async {
    Either<MyError, Null> returnEither = Right(null);
    try {
      nonce = await client.getTransactionCount(ownAddress);
      return Right(null);
    } catch (e) {
      returnEither = Left(MyError(
          key: AppError.DetermineNonceFailed,
          message: "Unable to determine the nonce"));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> deposit(BigInt amount) async {
    Either<MyError, Null> returnEither = Right(null);
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: deployedContract,
              function: deployedContract.function('deposit'),
              parameters: [],
              value: EtherAmount.fromBigInt(EtherUnit.wei, amount),
              nonce: nonce),
          chainId: chainId);
      nonce++;
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      updateNonce();
      returnEither = Left(MyError(
        key: AppError.SmartContractTransactionFailed,
        message: "The deposit transaction failed",
      ));
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
              contract: deployedContract,
              function: deployedContract.function('create_user'),
              parameters: [name, description]),
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
      nonce++;
    } catch (e) {
      updateNonce();
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The create_user transaction failed"));
    } finally {
      await client.dispose();
    }
    return returnEither;
  }

  Future<Either<MyError, Null>> withdraw(BigInt amount) async {
    Either<MyError, Null> returnEither = Right(null);
    try {
      String tx_hash = await client.sendTransaction(
          ownCredentials,
          Transaction.callContract(
              contract: deployedContract,
              function: deployedContract.function('withdraw_to_chain'),
              parameters: [amount]),
          chainId: chainId);
      TransactionReceipt? tx_receipt =
          await client.getTransactionReceipt(tx_hash);
    } catch (e) {
      print(e);
      updateNonce();
      returnEither = Left(MyError(
          key: AppError.SmartContractTransactionFailed,
          message: "The withdraw transaction failed"));
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
          contract: deployedContract,
          function: deployedContract.function('get_rand_distributor'),
          params: [song, generateRandom256BitNumber()]);
      if (outputList.length > 0) {
        returnEither = Right(outputList);
      } else {
        returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The get_rand_distributor call failed",
        ));
      }
    } catch (e) {
      updateNonce();

      print("Exception! $e and outputlist ${outputList[0]}");
      returnEither = Left(MyError(
          key: AppError.SmartContractCallFailed,
          message: "The get_rand_distributor call failed"));
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
          contract: deployedContract,
          function: deployedContract.function('get_songs'),
          params: [index, amount]);
      returnEither = Right(outputList);
    } catch (e) {
      returnEither = Left(MyError(
        key: AppError.SmartContractCallFailed,
        message: "The get_songs call failed",
      ));
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
          contract: deployedContract,
          function: deployedContract.function('song_list_length'),
          params: []);
      returnEither = Right(outputList);
    } catch (e) {
      returnEither = Left(MyError(
        key: AppError.SmartContractCallFailed,
        message: "The songs_list_length call failed",
      ));
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
          contract: deployedContract,
          function: deployedContract.function('users'),
          params: [EthereumAddress.fromHex(address)]);
      returnEither = Right(outputList);
    } catch (e) {
      returnEither = Left(MyError(
        key: AppError.SmartContractCallFailed,
        message: "The users call failed",
      ));
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
          contract: deployedContract,
          function: deployedContract.function('songs'),
          params: [song]);
      returnEither = Right(outputList);
    } catch (e) {
      returnEither = Left(MyError(
        key: AppError.SmartContractCallFailed,
        message: "The songs call failed",
      ));
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
          "uuu createChunkGetTransaction index $index amount $amount with nonce $nonce");
      // client.signTransaction(credentials, )
      Uint8List data = deployedContract.function('get_chunks').encodeCall([
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
    } catch (e) {
      returnEither = Left(MyError(
          key: AppError.SmartContractSignTransactionFailed,
          message:
              "Failed encoding and/or signing the get_chunks transaction"));
    }
    return returnEither;
  }
}
