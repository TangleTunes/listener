import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'smart_contract.dart';

const int chunkSize = 32500; //used to be 32766

class DistributorContact {
  late SmartContract smartContract;
  String distributorHex;
  String distributorUrl;
  Credentials ownCredentials;

  late Socket socket; // FIXME
  late Stream<Tuple2<int, Uint8List>> stream;

  DistributorContact(
    this.smartContract,
    this.ownCredentials,
    this.distributorHex,
    this.distributorUrl,
  ) {
    initialize();
  }

  int readInt32(ListQueue<int> queue, int startAt) {
    Uint8List resultData = Uint8List(4);
    for (int i = 0; i < 4; i++) {
      resultData[i] = queue.elementAt(i + startAt);
    }
    final byteData = ByteData.view(resultData.buffer);
    return byteData.getUint32(0, Endian.little);
  }

  void initialize() async {
    Uri uri = Uri.parse(distributorUrl);
    socket = await Socket.connect(uri.host, uri.port); //FIXME
    stream = socket.transform(StreamTransformer.fromBind((tcpStream) async* {
      ListQueue<int> queue = ListQueue();

      await for (final tcp_msg in tcpStream) {
        queue.addAll(tcp_msg);

        if (queue.length >= 8) {
          int chunkId = readInt32(queue, 0);
          int contentLength = readInt32(queue, 4);

          if (queue.length >= contentLength) {
            //oentire response from distributor in queue!
            for (int i = 0; i < 8; i++) {
              //remove  header of tcp messsage
              queue.removeFirst();
            }
            int bytesLeftInTcpMsg = contentLength;
            int chunkAmount = (contentLength / chunkSize).ceil();
            while (bytesLeftInTcpMsg > 0) {
              int chunkLength;
              if (bytesLeftInTcpMsg > chunkSize) {
                chunkLength = chunkSize;
              } else {
                chunkLength = bytesLeftInTcpMsg;
              }
              Uint8List chunk = Uint8List(chunkLength);
              int index = 0;
              for (final byte in queue.take(chunkLength)) {
                chunk[index] = byte;
                index++;
              }
              for (int j = 0; j < index; j++) {
                //pop bytes that we just read
                queue.removeFirst();
              }
              bytesLeftInTcpMsg = bytesLeftInTcpMsg - chunkLength;
              yield Tuple2(chunkId, chunk);
              chunkId++;
            }
          }
        }
      }
    })).asBroadcastStream();
  }

  Future<void> requestChunk(
      String songIdentifier, int chunk, int amount, int nonce) async {
    print("Tcp requested chunk $chunk");
    Uint8List songId = hexToBytes(songIdentifier);
    await sendTcpChunkRequest(songId, chunk, amount, socket, nonce);
  }

  Future<void> sendTcpChunkRequest(Uint8List songId, int chunkNum, int amount,
      Socket socket, int nonce) async {
    Uint8List BODY = await smartContract.createChunkGetTransaction(
        songId, chunkNum, amount, distributorHex, nonce);
    //Add body length as header (4 bytes)

    int bodyLength = BODY.length;
    final byteD = ByteData(4);
    byteD.setUint32(0, bodyLength, Endian.little);
    Uint8List HEADER = byteD.buffer.asUint8List();

    Uint8List PAYLOAD = Uint8List.fromList(HEADER + BODY);
    socket.add(PAYLOAD);
    await socket.flush();
    // await Future.delayed(Duration(seconds: 2));
  }
}
