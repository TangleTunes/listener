import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:listener13/distributer_contact.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  int numberOfStreams = 0;
  late String pathName;
  late DistributorContact distributorContact;
  late List<Uint8List> storedChunks;
  late List<bool> isChunkCached;
  final int chunkSize = 32766;
  late int fileSize;
  late ChunkStreamCreator chunkStream;

  MyCustomSource(this.pathName) {
    distributorContact = DistributorContact(pathName);
    chunkStream = ChunkStreamCreator(
        distributorContact, distributorContact.songIdentifier, this);
  }

  void initialze() async {
    fileSize = await distributorContact.giveMeFileSize();
    storedChunks = List.filled(
        fileSize ~/ chunkSize, Uint8List.fromList(List.filled(chunkSize, 0)));
    isChunkCached = List.filled(fileSize ~/ chunkSize, false);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    numberOfStreams++;
    print('.request method called with $start and $end');
    int fileSize = await distributorContact.giveMeFileSize();
    start ??= 0;
    end ??= fileSize;
    Stream<Uint8List> stream = chunkStream
        .createStream(start, storedChunks, isChunkCached, numberOfStreams)
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
