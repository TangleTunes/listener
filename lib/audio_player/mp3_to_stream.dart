import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:listener/audio_player/custom_audio_source.dart';
import 'package:listener/components/audioplayer.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:listener/distributor_connection/distributer_contact.dart';
import 'package:listener/utils/toast.dart';
import 'package:tuple/tuple.dart';

import '../error_handling/app_error.dart';

//used to be 32766
int paulsDummyTotal = 0;

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
  // bool isFinished = false;
  // The audio source
  Wrapper forWhatSource;
  // The next chunk number this stream should yield
  late int chunkNum;
  //Number of bytes in a chunk
  int chunkSize;

  ChunkStreamCreator(this.distributorContact, this.songIdentifier,
      this.fileSize, this.chunkSize, this.forWhatSource) {}

  Future<void> requestIfNotRequested(List<bool> isChunkRequested,
      Duration songDuration, AudioPlayer audioPlayer, int yourNum) async {
    // print(
    //     "called requestifnotrquested and isChunkRequested is $isChunkRequested ");
    int chunkToBeRequested = chunkNum;
    int currentChunkPositionInPlayback =
        ((audioPlayer.position.inMilliseconds / songDuration.inMilliseconds) *
                fileSize) ~/
            chunkSize;

    while (chunkToBeRequested < isChunkRequested.length &&
        isChunkRequested[chunkToBeRequested]) {
      //determine the next chunk that has not been requested
      chunkToBeRequested++;
    }
    // print(
    //     "6666 I am stream $yourNum and chunkToBeRequested is $chunkToBeRequested");

    // int currentBufferInPlayback = 0;

    // print(
    //     "vvv filesize: $fileSize, chunkToBeRequested $chunkToBeRequested currentChunkPosition: $currentBytePositionInPlayback, bufferSize $bufferSize");

    //is chukToBerequested in front of audioplayer.posiutin?
    // print(
    //     "I am stream $yourNum and is  $chunkToBeRequested >= $currentChunkPositionInPlayback? ${chunkToBeRequested >= currentChunkPositionInPlayback}");
    if ((chunkToBeRequested - currentChunkPositionInPlayback) < bufferSize &&
        chunkToBeRequested >= currentChunkPositionInPlayback) {
      fileSize;
      int requestRangeStart = chunkToBeRequested;
      int amount = 0;
      while (chunkToBeRequested < isChunkRequested.length &&
          !isChunkRequested[chunkToBeRequested] &&
          amount < requestAmount) {
        // print(
        //     "ppppp chunkToBeRequested $chunkToBeRequested , isChunkRequested.length ${isChunkRequested.length}, amount: $amount");

        amount++;
        isChunkRequested[chunkToBeRequested] = true;
        chunkToBeRequested++;
      }
      // print("pppp amount is $amount");
      if (amount != 0) {
        Either<MyError, Null> chunkReqCall = await distributorContact
            .requestChunks(songIdentifier, requestRangeStart, amount);

        // print(
        //     "7777 I am stream $yourNum and I am requesting $requestRangeStart, amouunt $amount");
        if (chunkReqCall.isLeft) {
          toast(chunkReqCall.left.message);
        }
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
    chunkNum = (startByte / chunkSize).floor();
    print("set chunkNum to be $chunkNum");
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
      if (forWhatSource.i == yourNum) {
        print(
            "okkk I am stream $yourNum, isFInished $isFinished, and is chunk  #$chunkNum cached? ${isChunkCached[chunkNum]}");
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
          paulsDummyTotal += chunk.length;
          // print(
          //     "I am stream $yourNum and yielding chunk $chunkNum which has size ${chunk.length} and paulsDummyTotal is $paulsDummyTotal");

          if (chunkNum < isChunkCached.length - 1) {
            chunkNum++;
          } else {
            // int totalLength = 0;
            // for (Uint8List cachedChunk in storedChunks) {
            //   totalLength += cachedChunk.length;
            // }
            // print(
            //     "we are finished, the total size of the stored chnuks is ${totalLength} and just audio thinks have ${audioPlayer.bufferedPosition} ${audioPlayer.duration}");
            isFinished = true;
          }
          // print(
          //     "yyyy just yielded chunk of size ${chunk.length} in storedChunks finished?: $isFinished chunkNum: $chunkNum");

          yield chunk;
        }

        if (val.runtimeType == Duration) {
          int milisec = (val as Duration).inMilliseconds;
          requestIfNotRequested(
              isChunkRequested, songDuration, audioPlayer, yourNum);
        }
      }
    }
  }
}
