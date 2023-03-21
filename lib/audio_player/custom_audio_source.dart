import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  Wrapper numberOfStreams = Wrapper();
  late String songIdentifier;
  late DistributorContact distributorContact;
  late List<Uint8List> storedChunks;
  late List<bool> isChunkCached;
  final int chunkSize = 32500;
  late int fileSize;
  late ChunkStreamCreator chunkStream;
  AudioPlayer audioPlayer;
  late List<bool> isChunkRequested;
  Duration songDuration;

  MyCustomSource(this.songIdentifier, this.audioPlayer, this.fileSize,
      this.distributorContact, this.songDuration) {
    chunkStream = ChunkStreamCreator(distributorContact, songIdentifier,
        fileSize, chunkSize, numberOfStreams);
    storedChunks = List.filled((fileSize / chunkSize).ceil(),
        Uint8List.fromList(List.filled(chunkSize, 0)));
    isChunkCached = List.filled((fileSize / chunkSize).ceil(), false);
    isChunkRequested = List.filled((fileSize / chunkSize).ceil(), false);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    numberOfStreams.i++;
    start ??= 0;
    end ??= fileSize;
    print("request method called with start $start and end $end");
    Stream<Uint8List> stream = chunkStream
        .createStream(start, storedChunks, isChunkCached, isChunkRequested,
            numberOfStreams.i, audioPlayer, songDuration)
        .asBroadcastStream();
    return StreamAudioResponse(
      sourceLength: fileSize,
      contentLength: end - start,
      offset: start,
      stream: stream,
      contentType: 'audio/mpeg',
    );
  }
}

class Wrapper {
  int i = 0;
}
