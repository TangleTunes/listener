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
  late SmartContract smartContract;
  String distributorHex;
  String distributorUrl;

  // Socket? socket; // FIXME

  DistributorContact(this.distributorHex, this.distributorUrl, String rpcUrl,
      String contractAddress) {
    initialize(rpcUrl, contractAddress);
  }

  Future initialize(String rpcUrl, String contractAddress) async {
    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);
    String privateKey = await loadPrivateKey();
    ByteData byteData = await rootBundle.load('assets/smartcontract.abi.json');
    String abiCode = utf8.decode(byteData.buffer.asUint8List());
    smartContract = SmartContract(rpcUrl, contractAddr, privateKey, abiCode);
  }

  Future<Uint8List> giveMeChunk(String songIdentifier, int chunk) async {
    Uri uri = Uri.parse(distributorUrl);
    Socket socket = await Socket.connect(uri.host, uri.port); //FIXME

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
