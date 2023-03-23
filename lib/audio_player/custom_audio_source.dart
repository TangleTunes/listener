import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import '../providers/song_list_provider.dart';
import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  Wrapper numberOfStreams = Wrapper();
  late List<Uint8List> storedChunks;
  late List<bool> isChunkCached;
  final int chunkSize = 32500;
  late ChunkStreamCreator chunkStream;
  AudioPlayer audioPlayer;
  late List<bool> isChunkRequested;
  Song song;

  MyCustomSource(this.song, this.audioPlayer)
      : super(
            tag: MediaItem(
          id: hex.encode(song.songId),
          title: song.songName,
          artist: song.artist,
        )) {
    chunkStream = ChunkStreamCreator(song.distributorContact!,
        hex.encode(song.songId), song.byteSize, chunkSize, numberOfStreams);
    storedChunks = List.filled((song.byteSize / chunkSize).ceil(),
        Uint8List.fromList(List.filled(chunkSize, 0)));
    isChunkCached = List.filled((song.byteSize / chunkSize).ceil(), false);
    isChunkRequested = List.filled((song.byteSize / chunkSize).ceil(), false);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    numberOfStreams.i++;
    start ??= 0;
    end ??= song.byteSize;
    print("request method called with start $start and end $end");
    Stream<Uint8List> stream = chunkStream
        .createStream(start, storedChunks, isChunkCached, isChunkRequested,
            numberOfStreams.i, audioPlayer, Duration(seconds: song.duration))
        .asBroadcastStream();
    return StreamAudioResponse(
      sourceLength: song.byteSize,
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
