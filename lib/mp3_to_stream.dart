//bugged
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:listener13/distributer_contact.dart';

class ChunkStream {
  final chunkSize = 32766;
  String songIdentifier;
  bool isFinished = false;
  DistributorContact distributorContact;

  AudioPlayer _audioPlayer;

  ChunkStream(
      this.distributorContact, this.songIdentifier, this._audioPlayer) {}

  Stream<Uint8List> createStream(int startByte, List<Uint8List> storedChunks,
      List<bool> isChunkCached) async* {
    var length = await distributorContact.giveMeFileSize();
    bool isFinished = false;
    int chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    //Check whether the chunk in question is already cached on this device

    late Uint8List chunk;

    await for (final position in _audioPlayer.positionStream) {
      var buf = _audioPlayer.bufferedPosition;
      // int acceptable = durationToChunk(_audioPlayer.position) + 2;

      print('I am stream resp for $startByte, then $position, $buf');
      while (_audioPlayer.bufferedPosition <=
          _audioPlayer.position + Duration(seconds: 4)) {
        print("is smaller");
        if (isChunkCached[chunkNum]) {
          // print('cached chunk $chunkNum');
          chunk = storedChunks[chunkNum];
          yield chunk;
        } else {
          // print('chunkNum is $chunkNum and must be samller than $acceptable ');

          chunk = await distributorContact.giveMeChunk(chunkNum);
          storedChunks[chunkNum] = chunk;
          isChunkCached[chunkNum] = true;

          if (isFirst) {
            yield chunk.sublist(offsetWithinChunk);
          } else {
            yield chunk;
          }
          isFirst = false;
          await Future.delayed(Duration(milliseconds: 100)); //sleep
          chunkNum += 1;
          if (chunkNum * chunkSize > length) {
            isFinished = true;
            return;
          }
        }
      }
    }
  }

  int durationToChunk(Duration d) {
    return (d.inSeconds * 16000) ~/ chunkSize;
  }
}
