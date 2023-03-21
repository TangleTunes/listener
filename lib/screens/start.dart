import 'dart:async';
import 'dart:convert';
import 'package:either_dart/src/either.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener/audio_player/playback.dart';
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

  _fetchPrefs(BuildContext context) async {
    // writeToFile(
    //     "pk.json", "destroyed"); //TODO remove this line. for dev purposes only
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
        Text("Starting app..."),
        shouldProceed
            ? ElevatedButton(
                onPressed: () {
                  goToPage(context, "/discovery");

                  //move to next screen and pass the prefs if you want
                },
                child: Text("Continue"),
              )
            : CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ]),
    ));
  }
}