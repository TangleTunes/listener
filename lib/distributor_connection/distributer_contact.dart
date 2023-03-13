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
  Credentials ownCredentials;

  late Socket socket; // FIXME
  late StreamIterator<Uint8List> stream;

  DistributorContact(
    this.smartContract,
    this.ownCredentials,
    this.distributorHex,
    this.distributorUrl,
  ) {
    initialize();
  }

  void initialize() async {
    Uri uri = Uri.parse(distributorUrl);
    socket = await Socket.connect(uri.host, uri.port); //FIXME
    stream = StreamIterator(
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
    })));
  }

  Future<Null> requestChunk(String songIdentifier, int chunk) async {
    Uint8List songId = hexToBytes(songIdentifier);
    sendTcpChunkRequest(songId, chunk, 1, socket);
    await socket.flush();
  }

  Future<Uint8List> nextChunk() async {
    if (await stream.moveNext()) {
      return stream.current;
    } else {
      throw "Socket was closed";
    }
  }

  Future<Uint8List> giveMeChunk(String songIdentifier, int chunk) async {
    print("calleing give me chunk $chunk");
    requestChunk(songIdentifier, chunk);
    return nextChunk();
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
