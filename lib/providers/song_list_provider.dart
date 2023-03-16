import 'package:flutter/material.dart';

class SongListProvider with ChangeNotifier {
  List<Song> _songsList = [];

  List<Song> getSongsList() {
    return _songsList;
  }

  void setSongsList(List<Song> songs) {
    _songsList = songs;
  }

  void updateSongListWithANewSong(Song song) {
    _songsList.add(song);
    notifyListeners();
  }
}

class Song {
  String songName;
  String artist;
  int duration;
  int price;

  Song({
    required this.songName,
    required this.artist,
    required this.duration,
    required this.price,
  });
}
