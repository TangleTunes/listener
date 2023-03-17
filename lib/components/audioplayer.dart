// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:typed_data';

import 'package:either_dart/either.dart';
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
import '../error_handling/app_error.dart';
import '../error_handling/toast.dart';
import '../providers/song_list_provider.dart';

@override
Widget audioPlayer(BuildContext context) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.watch<CurrentSongProvider>().getSong().songName,
              style: TextStyle(
                  color: COLOR_SECONDARY,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          Text(
              context
                  .watch<CurrentSongProvider>()
                  .getSong()
                  .artist
                  .toUpperCase(),
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
              toast("Finding a distributor");
              Either<MyError, List<dynamic>> scDistributorAnswer =
                  await sc.getRandDistributor(currentSong.songId);
              if (scDistributorAnswer.isRight) {
                String distributorHex = scDistributorAnswer.right[0].hex;
                Uri uri = Uri.parse("tcp://" + scDistributorAnswer.right[1]);
                Either<MyError, DistributorContact> dc =
                    await DistributorContact.create(
                        sc, distributorHex, uri.host, uri.port);
                if (dc.isRight) {
                  context.read<CurrentSongProvider>().setDistributor(dc.right);
                } else {
                  toast(dc.left.message);
                }

                Playback playback =
                    context.read<PlaybackProvider>().getPlayback();

                Uint8List songidBytes = currentSong.songId;
                String songIdentifier = hex.encode(songidBytes);
                if (currentSong.distributorContact != null) {
                  Either<MyError, Null> setAudio = await playback.setAudio(
                      songIdentifier,
                      currentSong.byteSize,
                      currentSong.distributorContact as DistributorContact);
                  if (setAudio.isRight) {
                  } else {
                    toast(setAudio.left.message);
                  }
                } else {
                  toast("No node is distributing this song");
                }
              } else {
                toast(scDistributorAnswer.left.message);
                Navigator.pushNamed(context, "/smart_contract_settings");
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
