import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String pk = "";
  _fetchPrefs() async {
    print("_fetchPrefs");
    //FIXME the following block of code should be replaced with user interactions
    //----------------------------------------------------------------------
    ByteData byteData = await rootBundle.load("assets/privatekey.json");
    String loadJson = utf8.decode(byteData.buffer.asUint8List());
    final decodedJson = jsonDecode(loadJson);
    pk = decodedJson['privatekey'];
    await setPrivateKey(pk, "pp");
    //------------------------------

    if (await alreadyCoupled()) {
      nextRoute = "/unlock";
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
    print("splash load pk inistate");
    super.initState();
    _fetchPrefs(); //running initialisation code; getting prefs etc.
  }

  @override
  Widget build(BuildContext context) {
    context.read<CredentialsProvider>().setOwnCredentials(pk);
    return Scaffold(
        //TODO replace this scafftold with a method call that returns a nice looking loading page with a given parameter "initialState" that specifies where the app should go once the user presses "contine"
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Load credentials"),
        shouldProceed
            ? ElevatedButton(
                onPressed: () {
                  //move to next screen and pass the prefs if you want
                  Navigator.pushNamed(context, nextRoute);
                },
                child: Text("Continue"),
              )
            : CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ]),
    ));
  }
}
