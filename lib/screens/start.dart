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
import 'package:local_auth/local_auth.dart';

// ···

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool shouldProceed = false;

  Future<String> _fetchPrefs(BuildContext context) async {
    return "/discovery";
  }

  @override
  void initState() {
    super.initState();
    _fetchPrefs(context); //running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(_fetchPrefs);
  }
}
