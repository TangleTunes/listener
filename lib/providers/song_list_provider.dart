import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';

class SongListProvider with ChangeNotifier {
  List<Song>? _songsList;

  List<Song>? getSongsList() {
    return _songsList;
  }

  void setSongsList(List<Song> songs) {
    _songsList = songs;
  }

  void updateSongListWithANewSong(Song song) {
    _songsList ??= [];
    _songsList?.add(song);
    notifyListeners();
  }
}

class Song {
  String songName;
  String artist;
  int duration;
  BigInt price;
  int byteSize;
  Uint8List songId;
  DistributorContact? distributorContact;

  Song({
    required this.songName,
    required this.artist,
    required this.duration,
    required this.price,
    required this.byteSize,
    required this.songId,
    this.distributorContact,
  });
}
