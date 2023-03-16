import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../user_settings/file_writer.dart';
import '../user_settings/manage_smart_contract_details.dart';
import '../distributor_connection/smart_contract.dart';
import '../providers/credentials_provider.dart';

class LoadingSmartContractInfo extends StatefulWidget {
  @override
  _LoadingSmartContractState createState() => _LoadingSmartContractState();
}

class _LoadingSmartContractState extends State<LoadingSmartContractInfo> {
  String nodeUrl = "";
  String contractAddr = "";
  int chainId = 0;
  String abi = "";
  bool shouldProceed = false;
  late SmartContract smartContract;

  _fetchPrefs(BuildContext context) async {
    await writeToFile("sc.toml",
        "making this toml file unreadbale so that initilizeSmartContractIfNotSet is always triggered and will contain what is set in asset's toml file"); //FIXME for development purposes only, remove this line
    await initilizeSmartContractIfNotSet();
    nodeUrl = await readNodeUrl();
    contractAddr = await readContractAdress();
    chainId = await readChainId();

    abi = await readAbiFromAssets();
    if (context.mounted) {
      Credentials credentials =
          context.read<CredentialsProvider>().getCredentials();
      smartContract = await SmartContract.create(
          nodeUrl, contractAddr, chainId, credentials, abi);
      context.read<SmartContractProvider>().setSmartContract(smartContract);
    }

    setState(() {
      shouldProceed = true; //got the prefs; set to some value if needed
    });
  }

  @override
  void initState() {
    print("inistate of splash sc");
    super.initState();
    print("super of splash sc done");
    _fetchPrefs(context); //running initialisation code; getting prefs etc.
    print("sfetchprefs done done");
  }

  @override
  Widget build(BuildContext context) {
    print("build method of sc check");
    return Scaffold(
        //TODO replace this scafftold with a method call that returns a nice looking loading page with a given parameter "initialState" that specifies where the app should go once the user presses "contine"
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Load smart contract"),
        shouldProceed
            ? ElevatedButton(
                onPressed: () {
                  //move to next screen and pass the prefs if you want
                  Navigator.pushNamed(context, "/load_songs");
                },
                child: Text("Continue"),
              )
            : CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ]),
    ));
  }
}
