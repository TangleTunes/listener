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

  Stream<Uint8List> createStream(int startByte) async* {
    var length = await distributorContact.giveMeFileSize();
    print('creating a stream $length');
    bool isFinished = false;
    int chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    while (!isFinished) {
      late Uint8List chunk;
      if (startByte + chunkSize > length) {
        // Uint8List chunk = await loadAudioFile('assets/jelte.mp3', pos, length);
        Uint8List chunk = await distributorContact.giveMeChunk(chunkNum);
        if (isFirst) {
          yield chunk.sublist(offsetWithinChunk);
        } else {
          yield chunk;
        }
      } else {
        // Uint8List chunk = await loadAudioFile('assets/jelte.mp3', pos, pos + chunkSize);
        Uint8List chunk = await distributorContact.giveMeChunk(chunkNum);
        if (isFirst) {
          yield chunk.sublist(offsetWithinChunk);
        } else {
          yield chunk;
        }
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
