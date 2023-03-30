import 'package:flutter/material.dart';
import 'package:listener/audio_player/playback.dart';
import 'package:listener/distributor_connection/distributer_contact.dart';
import 'package:listener/providers/song_list_provider.dart';
import 'package:web3dart/credentials.dart';
import '../distributor_connection/smart_contract.dart';

class PlaybackProvider with ChangeNotifier {
  Playback _playback = Playback();

  Playback getPlayback() {
    return _playback;
  }
}
