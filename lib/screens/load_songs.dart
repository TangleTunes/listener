import 'dart:async';
import 'dart:convert';
import 'package:either_dart/src/either.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener/audio_player/playback.dart';
import 'package:listener/components/loading_screen.dart';
import 'package:listener/error_handling/app_error.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/toast.dart';
import 'package:listener/providers/playback_provider.dart';
import 'package:listener/screens/account.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/current_song_provider.dart';
import '../providers/song_list_provider.dart';
import '../user_settings/file_writer.dart';
import '../user_settings/manage_smart_contract_details.dart';
import '../distributor_connection/smart_contract.dart';
import '../providers/credentials_provider.dart';

class LoadingSongs extends StatefulWidget {
  @override
  _LoadingSongsState createState() => _LoadingSongsState();
}

class _LoadingSongsState extends State<LoadingSongs> {
  bool shouldProceed = false;

  Future<String> _fetchPrefs(BuildContext context) async {
    SmartContract sc =
        context.read<SmartContractProvider>().getSmartContract()!;
    Either<MyError, List<dynamic>> potentialSongListLength =
        (await sc.songListLength());
    if (potentialSongListLength.isRight) {
      Either<MyError, List> potentialSongList =
          await sc.getSongs(BigInt.from(0), potentialSongListLength.right[0]);
      if (potentialSongList.isRight) {
        List<Song> songList = [];
        for (List<dynamic> scSong in potentialSongList.right[0]) {
          List<int> songId = scSong[0];
          String songName = scSong[1];
          String artist = scSong[2];
          BigInt price = scSong[3];

          BigInt byteLength = scSong[4];
          BigInt duration = scSong[5];
          songList.add(Song(
              songId: Uint8List.fromList(songId),
              byteSize: byteLength.toInt(),
              songName: songName,
              artist: artist,
              duration: duration.toInt(),
              price: price));
        }
        context.read<SongListProvider>().setSongsList(songList);
      } else {
        toast(potentialSongList.left.message);
      }
    } else {
      toast(potentialSongListLength.left.message);
    }
    return "/discovery";
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(_fetchPrefs);
  }
}
