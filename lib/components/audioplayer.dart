// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/current_song_provider.dart';
import 'package:listener/providers/playback_provider.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

import 'dart:typed_data';
import '../audio_player/playback.dart';
import '../error_handling/app_error.dart';
import '../utils/toast.dart';
import '../providers/song_list_provider.dart';

@override
Widget audioPlayer(BuildContext context) {
  if (context.watch<CurrentSongProvider>().getSong() == null) {
    return SizedBox.shrink();
  } else {
    return Column(children: [
      ValueListenableBuilder<ProgressBarState>(
        valueListenable:
            context.read<PlaybackProvider>().getPlayback().progressNotifier,
        builder: (_, value, __) {
          return ProgressBar(
            thumbColor: COLOR_TERTIARY,
            // thumbGlowColor: COLOR_TERTIARY,
            progressBarColor: COLOR_TERTIARY,
            bufferedBarColor: COLOR_QUATERNARY,
            baseBarColor: COLOR_SECONDARY,
            thumbGlowRadius: 15,
            onSeek: context.read<PlaybackProvider>().getPlayback().seek,
            progress: value.current,
            buffered: value.buffered,
            total: value.total,
          );
        },
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Center(
              child: Column(children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.start,

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.watch<CurrentSongProvider>().getSong()!.songName,
                    style: TextStyle(
                        color: COLOR_SECONDARY,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                Text(
                    context
                        .watch<CurrentSongProvider>()
                        .getSong()!
                        .artist
                        .toUpperCase(),
                    style: TextStyle(
                      color: Color(0xFFA5C0FF).withOpacity(0.7),
                      fontSize: 11,
                    )),
              ],
            )
          ])),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
          child: Row(
            children: [
              ValueListenableBuilder<ButtonState>(
                valueListenable: context
                    .read<PlaybackProvider>()
                    .getPlayback()
                    .buttonNotifier,
                builder: (_, value, __) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 32.0,
                        height: 32.0,
                        child: const CircularProgressIndicator(
                            color: COLOR_SECONDARY),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        color: COLOR_SECONDARY,
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed:
                            context.read<PlaybackProvider>().getPlayback().play,
                      );
                    case ButtonState.playing:
                      return IconButton(
                        color: COLOR_SECONDARY,
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                        onPressed: context
                            .read<PlaybackProvider>()
                            .getPlayback()
                            .pause,
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ])
    ]);
  }
}
