import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:listener13/distributer_contact.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  Wrapper numberOfStreams = Wrapper();
  late String pathName;
  late DistributorContact distributorContact;
  late List<Uint8List> storedChunks;
  late List<bool> isChunkCached;
  final int chunkSize = 32766;
  late int fileSize;
  late ChunkStreamCreator chunkStream;
  AudioPlayer audioPlayer;

  MyCustomSource(this.pathName, this.audioPlayer) {
    distributorContact = DistributorContact(pathName);
    chunkStream = ChunkStreamCreator(
        distributorContact, distributorContact.songIdentifier, numberOfStreams);
  }

  void initialze() async {
    fileSize = await distributorContact.giveMeFileSize();
    storedChunks = List.filled(fileSize ~/ chunkSize + 1,
        Uint8List.fromList(List.filled(chunkSize, 0)));
    isChunkCached = List.filled(fileSize ~/ chunkSize + 1, false);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    numberOfStreams.i++;
    print('.request method called with $start and $end');
    int fileSize = await distributorContact.giveMeFileSize();
    start ??= 0;
    end ??= fileSize;
    Stream<Uint8List> stream = chunkStream
        .createStream(
            start, storedChunks, isChunkCached, numberOfStreams.i, audioPlayer)
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
