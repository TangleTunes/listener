import 'dart:async';
import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener13/error_handling/toast.dart';
import 'package:listener13/screens/account.dart';
import 'package:listener13/screens/discovery.dart';
import 'package:listener13/screens/load_songs.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';
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
  late WidgetBuilder nextPage;

  _fetchPrefs(BuildContext context) async {
    nextPage = (context) => LoadingSongs();
    await writeToFile("sc.toml",
        "making this toml file unreadbale so that initilizeSmartContractIfNotSet is always triggered and will contain what is set in asset's toml file"); //FIXME for development purposes only, remove this line
    await initilizeSmartContractIfNotSet();
    nodeUrl = await readNodeUrl();
    contractAddr = await readContractAdress();
    chainId = await readChainId();

    abi = await readAbiFromAssets();
    Credentials credentials =
        context.read<CredentialsProvider>().getCredentials();
    Either<MyError, SmartContract> potentialSc =
        await SmartContract.create(nodeUrl, contractAddr, chainId, credentials);
    if (potentialSc.isRight) {
      smartContract = potentialSc.right;
      context.read<SmartContractProvider>().setSmartContract(smartContract);
    } else {
      toast(potentialSc.left.message);
      nextPage = (context) => AccountPage(tabSelected: 1);
    }

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
        Text("Load smart contract"),
        shouldProceed
            ? ElevatedButton(
                onPressed: () {
                  //move to next screen and pass the prefs if you want
                  print("hereee");
                  Navigator.push(context, MaterialPageRoute(builder: nextPage));
                },
                child: Text("Continue"),
              )
            : CircularProgressIndicator(), //show splash screen here instead of progress indicator
      ]),
    ));
  }
}
