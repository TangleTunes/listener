import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:listener13/distributor_connection/distributer_contact.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  Wrapper numberOfStreams = Wrapper();
  late String songIdentifier;
  late DistributorContact distributorContact;
  late List<Uint8List> storedChunks;
  late List<bool> isChunkCached;
  final int chunkSize = 35000;
  late int fileSize;
  late ChunkStreamCreator chunkStream;
  AudioPlayer audioPlayer;
  late List<bool> isChunkRequested;

  MyCustomSource(this.songIdentifier, this.audioPlayer, this.fileSize,
      this.distributorContact) {
    chunkStream = ChunkStreamCreator(
        distributorContact, songIdentifier, fileSize, numberOfStreams);
  }

  void initialze() async {
    storedChunks = List.filled(fileSize ~/ chunkSize + 1,
        Uint8List.fromList(List.filled(chunkSize, 0)));
    isChunkCached = List.filled(fileSize ~/ chunkSize + 1, false);
    isChunkRequested = List.filled(fileSize ~/ chunkSize + 1, false);

    // audioPlayer.positionStream.listen((event) {
    //   // if buffer < 10
    //   // request new chunks over tcp
    // });
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    numberOfStreams.i++;
    start ??= 0;
    end ??= fileSize;
    print("request method called with start $start and end $end");
    Stream<Uint8List> stream = chunkStream
        .createStream(start, storedChunks, isChunkCached, isChunkRequested,
            numberOfStreams.i, audioPlayer)
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
