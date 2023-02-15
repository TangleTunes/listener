import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  MyCustomSource();

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print("start is $start, end is $end");
    start ??= 0;
    end ??= 1956606;
    ByteCreator myByteCreator = ByteCreator();
    Stream<Uint8List> myStream = myByteCreator.stream;
    return StreamAudioResponse(
      sourceLength: 300000,
      contentLength: end - start,
      offset: start,
      stream: myStream,
      contentType: 'audio/mpeg', //MIME type of mp3 is mpeg
    );
  }
}

class ByteCreator {
  var _count = 0;
  final _controller = StreamController<Uint8List>();
  Stream<Uint8List> get stream => _controller.stream;
  ByteCreator() {
    getAudioFileSize('assets/1234.mp3').then((fileLength) {
      Timer.periodic(Duration(seconds: 1), (t) {
        int nextCount = _count + 40000;
        if (nextCount >= fileLength) {
          nextCount = fileLength;
          loadAudioFile('assets/1234.mp3', _count, nextCount).then((value) {
            _controller.sink.add(value);
          });
          t.cancel(); //stop the timer
          _controller.close(); //close the stream
        } else {
          loadAudioFile('assets/1234.mp3', _count, nextCount).then((value) {
            _controller.sink.add(value);
          });
          _count = _count + 40000;
        }
      });
    });
  }
}
