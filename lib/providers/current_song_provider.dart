import 'package:flutter/material.dart';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:listener13/providers/song_list_provider.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';

class CurrentSongProvider with ChangeNotifier {
  Song? _song;

  Song? getSong() {
    return _song;
  }

  void updateSong(Song song) {
    _song = song;
    notifyListeners();
  }

  void setDistributor(DistributorContact distributor) {
    _song?.distributorContact = distributor;
    notifyListeners();
  }
}
