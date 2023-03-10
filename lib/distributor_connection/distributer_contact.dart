import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'smart_contract.dart';

class DistributorContact {
  final _chunkSize = 35000;
  String songIdentifier;
  int cost = 0;
  late int FILE_SIZE;

  // Socket? socket; // FIXME

  DistributorContact(this.songIdentifier);

  Future<int> giveMeFileSize() async {
    //ByteData data = await rootBundle.load(songIdentifier);
    //Uint8List byteList = data.buffer.asUint8List();
    // return byteList.length;
    return 2113939; // FIXME
  }

  Future initialize() async {
    // socket = await Socket.connect("localhost", 3000);
  }

  Future<Uint8List> giveMeChunk(int chunk) async {
    Future<Uint8List>? result = null;
    Socket socket = await Socket.connect("10.0.2.2", 3000); //FIXME

    /// 1. send tx-len
    /// 2. send iota-tx
    Uint8List songId = hexToBytes(songIdentifier);

    sendTcpChunkRequest(songId, chunk, 1, socket);

    /// 3. flush
    await socket.flush();
    // await Future.delayed(Duration(seconds: 10)); //sleep
    Stream<Uint8List> stream =
        socket.transform(StreamTransformer.fromBind((tcpStream) async* {
      ListQueue<int> queue = ListQueue();

      await for (final tcp_msg in tcpStream) {
        queue.addAll(tcp_msg);

        if (queue.length >= 8) {
          Uint8List bodyLength = Uint8List(4);

          for (int i = 4; i < 8; i++) {
            bodyLength[i - 4] = queue.elementAt(i);
          }
          final byteData = ByteData.view(bodyLength.buffer);
          int contentLength = byteData.getUint32(0, Endian.little);
          if (queue.length >= contentLength) {
            //entire chunk in queue!
            for (int i = 0; i < 8; i++) {
              //remove first 8 elements
              queue.removeFirst();
            }
            Uint8List chunk = Uint8List(contentLength);
            int index = 0;
            for (final byte in queue.take(contentLength)) {
              chunk[index] = (byte);
              index++;
            }
            for (int j = 0; j < index; j++) {
              queue.removeFirst();
            }
            yield chunk;
          }
        }
      }
    }));

    return await stream.first;
  }

  void sendTcpChunkRequest(
      Uint8List songId, int chunkNum, int amount, Socket socket) async {
    String rpcUrl =
        "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm";
    EthereumAddress contractAddr =
        EthereumAddress.fromHex('0x8fA1fc1Eec824a36fD31497EAa8716Fc9C446d51');
    String privateKey = await loadPrivateKey();
    ByteData byteData = await rootBundle.load('assets/smartcontract.abi.json');
    String abiCode = utf8.decode(byteData.buffer.asUint8List());
    SmartContract smartContract =
        SmartContract(rpcUrl, contractAddr, privateKey, abiCode);
    await smartContract.init(rpcUrl, privateKey);
    String distributorHex = "0x74d0c7eb93c754318bca8174472a70038f751f2b";
    Uint8List BODY = await smartContract.createChunkGetTransaction(
        songId, chunkNum, amount, distributorHex);
    //Add body length as header (4 bytes)

    int bodyLength = BODY.length;
    final byteD = ByteData(4);
    byteD.setUint32(0, bodyLength, Endian.little);
    Uint8List HEADER = byteD.buffer.asUint8List();

    Uint8List PAYLOAD = Uint8List.fromList(HEADER + BODY);
    await sendMessage(socket, PAYLOAD);
  }

  Future<void> sendMessage(Socket socket, Uint8List message) async {
    socket.add(message);
    socket.flush();
    await Future.delayed(Duration(seconds: 2));
  }
}
