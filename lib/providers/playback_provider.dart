import 'package:flutter/material.dart';
import 'package:listener13/audio_player/playback.dart';
import 'package:listener13/distributor_connection/distributer_contact.dart';
import 'package:listener13/providers/song_list_provider.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';

class PlaybackProvider with ChangeNotifier {
  Playback _playback = Playback();

  Playback getPlayback() {
    return _playback;
  }

  void setPlayback(Playback playback) {
    _playback = playback;
    notifyListeners();
  }
}
