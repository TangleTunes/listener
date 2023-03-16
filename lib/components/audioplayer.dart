// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:listener13/providers/current_song_provider.dart';
import 'package:listener13/providers/playback_provider.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:listener13/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

import 'dart:typed_data';
import '../audio_player/playback.dart';
import '../providers/song_list_provider.dart';

@override
Widget audioPlayer(BuildContext context) {
  Song song = context.read<CurrentSongProvider>().getSong();
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(song.songName,
              style: TextStyle(
                  color: COLOR_SECONDARY,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          Text(song.artist.toUpperCase(),
              style: TextStyle(
                color: Color(0xFFA5C0FF).withOpacity(0.7),
                fontSize: 11,
              )),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: null,
            iconSize: 35,
            icon: Icon(
              Icons.skip_previous,
              color: COLOR_SECONDARY,
            ),
          ),
          IconButton(
            onPressed: () async {
              SmartContract sc =
                  context.read<SmartContractProvider>().getSmartContract();
              Song currentSong = context.read<CurrentSongProvider>().getSong();
              Fluttertoast.showToast(
                  msg: "Finding a distributor...",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              List<dynamic> scDistributorAnswer =
                  await sc.getRandDistributor(currentSong.songId);
              String distributorHex = scDistributorAnswer[0].hex;
              String ip = scDistributorAnswer[1];
              DistributorContact dc = await DistributorContact.create(
                  sc, distributorHex, ("http://$ip"));
              context.read<CurrentSongProvider>().setDistributor(dc);
              Playback playback =
                  context.read<PlaybackProvider>().getPlayback();

              Uint8List songidBytes = currentSong.songId;
              String songIdentifier = hex.encode(songidBytes);
              if (currentSong.distributorContact != null) {
                playback.setAudio(songIdentifier, currentSong.byteSize,
                    currentSong.distributorContact as DistributorContact);
              } else {
                print(
                    "ERROR no distributor for playing the song ${currentSong.songName}");
              }
            },
            iconSize: 35,
            icon: Icon(
              Icons.play_arrow,
              color: COLOR_SECONDARY,
            ),
          ),
          IconButton(
            onPressed: null,
            iconSize: 35,
            icon: Icon(
              Icons.skip_next,
              color: COLOR_SECONDARY,
            ),
          )
        ],
      ),
    ),
  ]);
}
