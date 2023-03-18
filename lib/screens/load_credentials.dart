import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener13/components/loading_screen.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/providers/credentials_provider.dart';
import 'package:provider/provider.dart';

import '../distributor_connection/smart_contract.dart';
import '../providers/smart_contract_provider.dart';

class LoadingCredentials extends StatefulWidget {
  @override
  _LoadingCredentialsState createState() => _LoadingCredentialsState();
}

class _LoadingCredentialsState extends State<LoadingCredentials> {
  bool shouldProceed = false;
  String nextRoute = "/";
  _fetchPrefs() async {
    //FIXME the following block of code should be removed
    //----------------------------------------------------------------------
    // ByteData byteData = await rootBundle.load("assets/privatekey.json");
    // String loadJson = utf8.decode(byteData.buffer.asUint8List());
    // final decodedJson = jsonDecode(loadJson);
    // pk = decodedJson['privatekey'];
    // await setPrivateKey(pk, "pp");
    //------------------------------

    if (await alreadyCoupled()) {
      nextRoute = "/unlock_account";
      print("already coupled");
    } else {
      nextRoute = "/create_account";
      print("not coupled");
    }
    setState(() {
      shouldProceed = true; //got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPrefs(); //running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    return makeLoadingScreen(
        context, "Loading credentials", nextRoute, shouldProceed);
  }
}
