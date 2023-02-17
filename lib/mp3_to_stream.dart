import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:typed_data';

import 'package:listener13/distributer_contact.dart';

class ChunkStream {
  final chunkSize = 32766;
  String songIdentifier;
  bool isFinished = false;
  DistributorContact distributorContact;

  ChunkStream(this.distributorContact, this.songIdentifier) {}

  Stream<Uint8List> createStream(int startByte, List<Uint8List> storedChunks,
      List<bool> isChunkCached) async* {
    var length = await distributorContact.giveMeFileSize();
    bool isFinished = false;
    int chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    while (!isFinished) {
      //Check whether the chunk in question is already cached on this device

      late Uint8List chunk;
      if (isChunkCached[chunkNum]) {
        chunk = storedChunks[chunkNum];
      } else {
        chunk = await distributorContact.giveMeChunk(chunkNum);
        storedChunks[chunkNum] = chunk;
        isChunkCached[chunkNum] = true;
      }

      if (isFirst) {
        yield chunk.sublist(offsetWithinChunk);
      } else {
        yield chunk;
      }
      isFirst = false;
      await Future.delayed(Duration(seconds: 1)); //sleep
      chunkNum += 1;
      if (chunkNum * chunkSize > length) {
        isFinished = true;
        return;
      }
    }
  }
}
