import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:listener13/custom_audio_source.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:listener13/distributer_contact.dart';

class ChunkStreamCreator {
  final chunkSize = 32766;
  String songIdentifier;
  bool isFinished = false;
  DistributorContact distributorContact;

  Wrapper forWhatSource;

  ChunkStreamCreator(
      this.distributorContact, this.songIdentifier, this.forWhatSource) {}

  Stream<Uint8List> createStream(int startByte, List<Uint8List> storedChunks,
      List<bool> isChunkCached, int yourNum) async* {
    var length = await distributorContact.giveMeFileSize();
    bool isFinished = false;
    int chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    while (!isFinished) {
      //Check whether the chunk in question is already cached on this device
      if (forWhatSource.i == yourNum) {
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
          var chunkLen = chunk.length;
          yield chunk;
        }
        // print('I am resp for $startByte and YES yieling stuff');
        isFirst = false;
        await Future.delayed(Duration(seconds: 1)); //sleep
        chunkNum += 1;
        if (chunkNum * chunkSize >= length) {
          isFinished = true;
          return;
        }
      } else {
        isFinished = true;
        // print('I am resp for $startByte and NOT yieling stuff');
      }
    }
  }
}
