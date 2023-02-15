import 'dart:async';

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
    Stream<List<int>> myStream = myByteCreator.stream;
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
  final _controller = StreamController<List<int>>();
  Stream<List<int>> get stream => _controller.stream;
  ByteCreator() {
    getAudioFileSize('assets/1234.mp3').then((fileLength) {
      Timer.periodic(Duration(seconds: 1), (t) {
        int nextCount = _count + 20000;
        if (_count + 40000 >= fileLength) {
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
          _count = _count + 20000;
        }
      });
    });
  }
}
