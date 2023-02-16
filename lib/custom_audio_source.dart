import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  late String pathName;
  late Stream<Uint8List> stream;
  late File file;
  late int fileLength;

  MyCustomSource(this.pathName) {
    file = File(pathName);

    init();
    stream = createStream(file).asBroadcastStream();
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print('.request method called with $start and $end');
    start ??= 0;
    end ??= fileLength;
    return StreamAudioResponse(
      sourceLength: fileLength,
      contentLength: end - start,
      offset: start,
      stream: stream,
      contentType: 'audio/mpeg',
    );
  }

  void init() async {
    fileLength = await getAudioFileSize(pathName);
  }
}
