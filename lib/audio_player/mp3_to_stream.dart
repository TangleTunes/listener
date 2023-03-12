import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:listener13/audio_player/custom_audio_source.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:listener13/distributor_connection/distributer_contact.dart';

class ChunkStreamCreator {
  final chunkSize = 32500; //used to be 32766
  String songIdentifier;
  bool isFinished = false;
  DistributorContact distributorContact;
  int fileSize;
  Wrapper forWhatSource;

  ChunkStreamCreator(this.distributorContact, this.songIdentifier,
      this.fileSize, this.forWhatSource) {}

  Stream<Uint8List> createStream(int startByte, List<Uint8List> storedChunks,
      List<bool> isChunkCached, int yourNum, AudioPlayer audioPlayer) async* {
    bool isFinished = false;
    int chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    await for (final position in audioPlayer.positionStream) {
      while (audioPlayer.bufferedPosition <= position + Duration(seconds: 10) &&
          !isFinished) {
        if (forWhatSource.i == yourNum) {
          late Uint8List chunk;
          if (isChunkCached[chunkNum]) {
            chunk = storedChunks[chunkNum];
          } else {
            print("await distributorContact.giveMeChunk(chunkNum)");
            chunk =
                await distributorContact.giveMeChunk(songIdentifier, chunkNum);
            storedChunks[chunkNum] = chunk;
            isChunkCached[chunkNum] = true;
          }

          if (isFirst) {
            yield chunk.sublist(offsetWithinChunk);
          } else {
            var chunkLen = chunk.length;
            yield chunk;
          }
          isFirst = false;
          await Future.delayed(Duration(milliseconds: 100)); //sleep
          chunkNum += 1;
          if (chunkNum * chunkSize >= fileSize) {
            isFinished = true;
            return;
          }
        } else {
          isFinished = true;
        }
      }
    }
  }
}
