import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'mp3_to_stream.dart';

class PageManager {
  late AudioPlayer _audioPlayer;
  PageManager() {
    _init();
  }
  void _init() async {
    _audioPlayer = AudioPlayer();
    final streamAudioSource = MyCustomSource();
    await _audioPlayer.setAudioSource(streamAudioSource);
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        // completed
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }

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
    getAudioFileSize('assets/cinematic.mp3').then((fileLength) {
      Timer.periodic(Duration(seconds: 1), (t) {
        int nextCount = _count + 20000;
        if (nextCount >= fileLength) {
          nextCount = fileLength;
          loadAudioFile('assets/cinematic.mp3', _count, nextCount)
              .then((value) {
            _controller.sink.add(value);
          });
          t.cancel(); //stop the timer
          _controller.close(); //close the stream
        } else {
          loadAudioFile('assets/cinematic.mp3', _count, nextCount)
              .then((value) {
            _controller.sink.add(value);
          });
          _count = _count + 20000;
        }
      });
    });
  }
}
