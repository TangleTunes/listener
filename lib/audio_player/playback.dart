import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';
import '../error_handling/app_error.dart';
import 'custom_audio_source.dart';

class Playback {
  late AudioPlayer _audioPlayer;
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  Playback() {
    _audioPlayer = AudioPlayer();
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
  Future<Either<MyError, Null>> setAudio(String songIdentifier, int sizeInBytes,
      DistributorContact distributorContact, Duration songDuration) async {
    final streamAudioSource = MyCustomSource(songIdentifier, _audioPlayer,
        sizeInBytes, distributorContact, songDuration);
    try {
      await _audioPlayer.setAudioSource(streamAudioSource);
      return Right(null);
    } catch (e) {
      return Left(MyError(
          key: AppError.PlaybackError,
          message: "Unable to set playback source"));
    }
  }

  void seek(Duration position) {
    print("user seeked to $position");
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
