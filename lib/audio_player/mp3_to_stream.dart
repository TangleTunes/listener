import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:listener/audio_player/custom_audio_source.dart';
import 'package:listener/components/audioplayer.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:listener/distributor_connection/distributer_contact.dart';
import 'package:tuple/tuple.dart';

//used to be 32766

class ChunkStreamCreator {
  // How many chunks should be buffered as outgoing requests
  static int requestAmount = 10;
  static int bufferSize = 15;
  DistributorContact distributorContact;
  // THe size in bytes of the music file
  int fileSize;
  // The song-id as a hex-string
  String songIdentifier;
  // Stores whether this stream is still relevant for the audio player. It will be irrelevant eg when the user skips forward in the song and the .request method is called with a new start
  bool isFinished = false;
  // The audio source
  Wrapper forWhatSource;
  // The next chunk number this stream should yield
  late int chunkNum;
  //Number of bytes in a chunk
  int chunkSize;

  ChunkStreamCreator(this.distributorContact, this.songIdentifier,
      this.fileSize, this.chunkSize, this.forWhatSource) {}

  Future<void> requestIfNotRequested(List<bool> isChunkRequested,
      Duration songDuration, AudioPlayer audioPlayer) async {
    // print(
    //     "called requestifnotrquested and isChunkRequested is $isChunkRequested ");
    //v3

    int chunkToBeRequested = chunkNum;
    while (chunkToBeRequested < isChunkRequested.length &&
        isChunkRequested[chunkToBeRequested]) {
      //determine the next chunk that has not been requested
      chunkToBeRequested++;
    }
    int currentBytePositionInPlayback = 0;
    // int currentBufferInPlayback = 0;
    currentBytePositionInPlayback =
        ((audioPlayer.position.inMilliseconds / songDuration.inMilliseconds) *
                fileSize) ~/
            chunkSize;
    if ((chunkToBeRequested - currentBytePositionInPlayback) < bufferSize) {
      fileSize;
      int requestRangeStart = chunkToBeRequested;
      int amount = 0;
      while (chunkToBeRequested < isChunkRequested.length &&
          !isChunkRequested[chunkToBeRequested] &&
          amount < requestAmount) {
        amount++;
        isChunkRequested[chunkToBeRequested] = true;
        chunkToBeRequested++;
      }
      if (amount != 0) {
        await distributorContact.requestChunks(songIdentifier,
            requestRangeStart, amount); //FIXME no error handling at the moment
      }
    }
  }

  Stream<Uint8List> createStream(
      int startByte,
      List<Uint8List> storedChunks,
      List<bool> isChunkCached,
      List<bool> isChunkRequested,
      int yourNum,
      AudioPlayer audioPlayer,
      Duration songDuration) async* {
    bool isFinished = false;
    chunkNum = (startByte - 1) ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    Stream<Duration> dummyStream = Stream<Duration>.periodic(
        Duration(milliseconds: 200), (x) => audioPlayer.position);

    await for (final val
        in StreamGroup.merge([dummyStream, distributorContact.stream])) {
      if (val.runtimeType == Tuple2<int, Uint8List>) {
        val as Tuple2<int, Uint8List>;
        var chunkId = val.item1;
        var chunkData = val.item2;
        // print(
        //     "I am stream $yourNum and just recieved a tcp msg for chunk $chunkId");
        storedChunks[chunkId] = chunkData;
        isChunkCached[chunkId] = true;
      }
      if (forWhatSource.i == yourNum && !isFinished) {
        if (isChunkCached[chunkNum]) {
          //why is this not a while loop?
          Uint8List chunk;
          if (isFirst) {
            chunk = storedChunks[chunkNum].sublist(offsetWithinChunk);
            isFirst = false;
          } else {
            chunk = storedChunks[chunkNum];
          }
          // print(
          //     "I am stream $yourNum and yielding chunk $chunkNum which has size ${chunk.length}");
          if (chunkNum < isChunkCached.length - 1) {
            chunkNum++;
          } else {
            isFinished = true;
          }

          yield chunk;
        }

        if (val.runtimeType == Duration) {
          int milisec = (val as Duration).inMilliseconds;

          requestIfNotRequested(isChunkRequested, songDuration, audioPlayer);
        }
      }
    }
  }
}
