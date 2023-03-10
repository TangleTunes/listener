import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';

import 'package:tcp_socket_connection/tcp_socket_connection.dart';
import 'package:web3dart/web3dart.dart';

class DistributorTcp {
  void sendChunkReq(
      Uint8List songId, int chunkNum, int amount, Socket socket) async {
    String rpcUrl =
        "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
    EthereumAddress contractAddr =
        EthereumAddress.fromHex('0x8fA1fc1Eec824a36fD31497EAa8716Fc9C446d51');
    String privateKey = await loadPrivateKey();
    SmartContract smartContract = SmartContract(
        rpcUrl, contractAddr, privateKey, 'assets/smartcontract.abi.json');
    await smartContract.init(rpcUrl, privateKey);
    String distributorHex = "0x74d0c7eb93c754318bca8174472a70038f751f2b";
    Uint8List BODY = await smartContract.createChunkGetTransactionTest(
        songId, chunkNum, amount, distributorHex);
    //Add body length as header (4 bytes)

    int bodyLength = BODY.length;
    final byteD = ByteData(4);
    byteD.setUint32(0, bodyLength, Endian.little);
    Uint8List HEADER = byteD.buffer.asUint8List();

    Uint8List PAYLOAD = Uint8List.fromList(HEADER + BODY);
    print("I sent this signed transaction: $PAYLOAD");
    await sendMessage(socket, PAYLOAD);
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
  }

  Future<void> sendMessage(Socket socket, Uint8List message) async {
    socket.add(message);
    socket.flush();
    await Future.delayed(Duration(seconds: 2));
  }
}
