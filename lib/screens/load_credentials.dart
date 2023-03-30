import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener/components/loading_screen.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/utils/go_to_page.dart';
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
  Future<String> _fetchPrefs(BuildContext context) async {
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
    return nextRoute;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingScreen(_fetchPrefs);
  }
}
