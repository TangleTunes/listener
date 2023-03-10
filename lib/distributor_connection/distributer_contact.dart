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

  Socket? socket; // FIXME

  DistributorContact(this.songIdentifier);

  Future<int> giveMeFileSize() async {
    //ByteData data = await rootBundle.load(songIdentifier);
    //Uint8List byteList = data.buffer.asUint8List();
    // return byteList.length;
    return 0; // FIXME
  }

  Future initialize() async {
    socket = await Socket.connect("localhost", 3000);
  }

  Future<Uint8List> requestChunk(int chunk) async {
    Future<Uint8List>? result = null;

    /// 1. send tx-len
    /// 2. send iota-tx
    Uint8List songId = hexToBytes(songIdentifier);
    DistributorTcp distributorTcp = DistributorTcp();
    distributorTcp.sendChunkReq(songId, chunk, 1, socket!);

    /// 3. flush
    await socket!.flush();
    print("Socket flushed, now sleeping");
    // await Future.delayed(Duration(seconds: 10)); //sleep
    var stream = socket!.transform(StreamTransformer.fromBind((stream) async* {
      ListQueue<int> queue = ListQueue();

      await for (final tcp_msg in stream) {
        queue.addAll(tcp_msg);

        if (queue.length >= 8) {
          //01001011 010101010
          Uint8List bodyLength = Uint8List(4);

          for (int i = 4; i < 8; i++) {
            bodyLength[i - 4] = queue.elementAt(i);
          }
          final byteData = ByteData.view(bodyLength.buffer);
          int contentLength = byteData.getUint32(0, Endian.little);

          // var bytes = bodyLength.buffer.asByteData();
          // int contentLength = bytes.getUint32(0);
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
            print("yielded chunk $chunk");
          }
        }
      }
    }));
    print("awaiting stream");
    return await stream.first;

    /// 4. receive chunk-id to buffer (store it)
    ///
    /// 5. receive chunk-len to buffer (store it)
    /// 6. receive chunk to buffer (and don't discard excessive bytes! store them for next recv)
    // listen for responses from the server
    // socket.listen(
    //   // handle data from the server
    //   (Uint8List data) async {
    //     queue.addAll(data);
    //     if (queue.length >= 8) {
    //       //01001011 010101010
    //       Uint8List temp = new Uint8List(4);

    //       for (int i = 4; i < 8; i++) {
    //         temp[i] = queue.elementAt(i);
    //       }
    //       var bytes = temp.buffer.asByteData();
    //       int contentLength = bytes.getUint32(0);
    //       if (queue.length >= contentLength) {
    //         //entire chunk in queue!
    //         for (int i = 0; i < 8; i++) {
    //           //remove first 8 elements
    //           queue.removeFirst();
    //         }
    //         Uint8List chunk = Uint8List(contentLength);
    //         for (final byte in queue.take(contentLength)) {
    //           chunk.add(byte);
    //         }
    //         for (final byte in queue.take(contentLength)) {
    //           queue.removeFirst();
    //         }

    //         //RETURN SOMETHING?!
    //         yield chunk;
    //       }
    //     }
    //   },

    //   // handle errors
    //   onError: (error) {
    //     print(error);
    //     socket.destroy();
    //   },

    //   // handle server ending connection
    //   onDone: () {
    //     print('Server left.');
    //     socket.destroy();
    //   },
    // );
  }

  Future<Uint8List> _loadAudioFile(String path, int start, int end) async {
    // ByteData data = await rootBundle.load(path);
    // Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
    // return byteList;
    return Uint8List(0); // FIXME
  }
}
