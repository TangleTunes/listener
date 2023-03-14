import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:listener13/audio_player/custom_audio_source.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:tuple/tuple.dart';

const int chunkSize = 32500; //used to be 32766

class ChunkStreamCreator {
  // How many chunks should be buffered as outgoing requests
  static int requestBufferSize = 5;
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

  late int nonce;

  ChunkStreamCreator(this.distributorContact, this.songIdentifier,
      this.fileSize, this.forWhatSource) {
    init();
  }

  void init() async {
    nonce = await distributorContact.smartContract.client
        .getTransactionCount(distributorContact.smartContract.ownAddress);
  }

  Future<void> requestIfNotRequested(List<bool> isChunkRequested) async {
    int requestRangeStart = chunkNum;
    int requestedChunk = chunkNum;
    while (requestedChunk < requestRangeStart + requestBufferSize) {
      int amount = 0;
      int chunkStart = requestedChunk;
      while (!isChunkRequested[requestedChunk] &&
          requestedChunk < requestRangeStart + requestBufferSize) {
        amount++;
        requestedChunk++;
      }
      print("sending a chunk request from $chunkStart with amount of $amount");
      await distributorContact.requestChunk(
          songIdentifier, chunkStart, amount, nonce);
    }
    // for (int i = chunkNum; i < chunkNum + requestBufferSize; i++) {
    //   if (!isChunkRequested[i]) {
    //     print("Sending chunk request $chunkNum with nonce $nonce");
    //     await distributorContact.requestChunk(songIdentifier, i, nonce);
    //     nonce++;
    //     isChunkRequested[i] = true;
    //   }
    // }
  }

  Stream<Uint8List> createStream(
      int startByte,
      List<Uint8List> storedChunks,
      List<bool> isChunkCached,
      List<bool> isChunkRequested,
      int yourNum,
      AudioPlayer audioPlayer) async* {
    bool isFinished = false;
    chunkNum = startByte ~/ chunkSize;
    int offsetWithinChunk = startByte % chunkSize;
    bool isFirst = true;

    await for (final val in StreamGroup.merge(
        [audioPlayer.positionStream, distributorContact.stream])) {
      if (forWhatSource.i != yourNum || isFinished) {
        return;
      }
      if (val.runtimeType == Duration) {
        await requestIfNotRequested(isChunkRequested);
      } else {
        //tcp stream yielded something
        val as Tuple2<int, Uint8List>;
        var chunkId = val.item1;
        var chunkData = val.item2;
        storedChunks[chunkId] = chunkData;
        isChunkCached[chunkId] = true;
        print("chunkId $chunkId");
      }
      print("Chunknum: $chunkNum");
      if (isChunkCached[chunkNum]) {
        Uint8List chunk;
        if (isFirst) {
          chunk = storedChunks[chunkNum].sublist(offsetWithinChunk);
          isFirst = false;
        } else {
          chunk = storedChunks[chunkNum];
        }
        print("yielding a chunk! ${chunkNum}");
        chunkNum++;
        if (chunkNum * chunkSize >= fileSize) {
          isFinished = true;
        }
        yield chunk;
      }
    }

    // await for (final position in audioPlayer.positionStream) {
    //   while (audioPlayer.bufferedPosition <= position + Duration(seconds: 10) &&
    //       !isFinished) {
    //     if (forWhatSource.i == yourNum) {
    //       late Uint8List chunk;
    //       if (isChunkCached[chunkNum]) {
    //         chunk = storedChunks[chunkNum];
    //       } else {
    //         chunk =
    //             await distributorContact.giveMeChunk(songIdentifier, chunkNum);
    //         storedChunks[chunkNum] = chunk;
    //         isChunkCached[chunkNum] = true;
    //       }

    //       if (isFirst) {
    //         yield chunk.sublist(offsetWithinChunk);
    //       } else {
    //         var chunkLen = chunk.length;
    //         yield chunk;
    //       }
    //       isFirst = false;
    //       await Future.delayed(Duration(milliseconds: 100)); //sleep
    //       chunkNum += 1;
    //       if (chunkNum * chunkSize >= fileSize) {
    //         isFinished = true;
    //         return;
    //       }
    //     } else {
    //       isFinished = true;
    //     }
    //   }
    // }
  }
}
