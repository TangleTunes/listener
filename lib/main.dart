import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:listener13/mp3_to_stream.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Listener 10 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Listener 10'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _playSong() {
    print('Button pressed!');
    setState(() {});
    // //PLAY THE SONG!
    playMusicFromStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: const <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _playSong,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Future<Stream<List<int>>> giveMeStream() async {
//   Stream<List<int>> fileStream = File('assets/stomp.mp3').openRead();
//   return fileStream;
// }

void playMusicFromStream() async {
  final player = AudioPlayer();

  // Uint8List bytes = await loadAudioFile('assets/stomp.mp3');
  // List<int> ints = bytes.toList().map((byte) => byte.toInt()).toList();
  final streamAudioSource = MyCustomSource();
  await player.setAudioSource(streamAudioSource);
  player.play();
}

class MyCustomSource extends StreamAudioSource {
  MyCustomSource();

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print("start is $start, end is $end");
    start ??= 0;
    end ??= 300000;
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
          _count = _count + 20000;
        }
      });
    });
  }
}
