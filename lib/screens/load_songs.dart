import 'dart:async';
import 'dart:convert';
import 'package:either_dart/src/either.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener13/audio_player/playback.dart';
import 'package:listener13/error_handling/app_error.dart';
import 'package:listener13/error_handling/toast.dart';
import 'package:listener13/providers/playback_provider.dart';
import 'package:listener13/screens/account.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
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

  _fetchPrefs(BuildContext context) async {
    SmartContract sc = context.read<SmartContractProvider>().getSmartContract();
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
              price: price.toInt()));
        }
        context.read<SongListProvider>().setSongsList(songList);

        Song firstSong = context.read<SongListProvider>().getSongsList()[0];
        print("fetched fistr song");
        context.read<CurrentSongProvider>().updateSong(firstSong);
        print("set current song to $firstSong");

        // context.read<PlaybackProvider>().setPlayback(Playback());
      } else {
        toast(potentialSongList.left.message);
        Navigator.pushNamed(context, "/smart_contract_settings");
      }
    } else {
      toast(potentialSongListLength.left.message);
      Navigator.pushNamed(context, "/smart_contract_settings");
    }
    setState(() {
      shouldProceed = true; //got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPrefs(context); //running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //TODO replace this scafftold with a method call that returns a nice looking loading page with a given parameter "initialState" that specifies where the app should go once the user presses "contine"
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Load songs"),
        shouldProceed
            ? ElevatedButton(
                onPressed: () {
                  //move to next screen and pass the prefs if you want
                  Navigator.pushNamed(
                      context, "/discovery"); //FIXME here should be discovery
                },
                child: Text("Continue"),
              )
            : CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ]),
    ));
  }
}
