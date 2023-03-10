import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

//import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';

import 'distributor_tcp.dart';

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
    return 0; // FIXME
  }

  Future initialize() async {
    // socket = await Socket.connect("localhost", 3000);
  }

  Future<Uint8List> requestChunk(int chunk) async {
    print("inside requestChunk method");
    Future<Uint8List>? result = null;
    Socket socket = await Socket.connect("10.0.2.2", 3000);
    print("socket created as $socket");

    /// 1. send tx-len
    /// 2. send iota-tx
    Uint8List songId = hexToBytes(songIdentifier);
    DistributorTcp distributorTcp = DistributorTcp();
    distributorTcp.sendChunkReq(songId, chunk, 1, socket);

    /// 3. flush
    await socket.flush();
    // await Future.delayed(Duration(seconds: 10)); //sleep
    print("creating stream from tcp");
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
          print("content length is $contentLength");
          print(
              "queue.length is ${queue.length}, contentLength is ${contentLength}");
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
    print("awaiting stream");

    return await stream.first;
  }

  Future<Uint8List> _loadAudioFile(String path, int start, int end) async {
    // ByteData data = await rootBundle.load(path);
    // Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
    // return byteList;
    return Uint8List(0); // FIXME
  }
}
