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

  Uint8List bytes = await loadAudioFile('assets/stomp.mp3');
  List<int> ints = bytes.toList().map((byte) => byte.toInt()).toList();
  final streamAudioSource = MyCustomSource(ints);
  await player.setAudioSource(streamAudioSource);
  player.play();
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg', //MIME type of mp3 is mpeg
    );
  }
}
