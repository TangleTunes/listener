import 'dart:async';
import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener/components/loading_screen.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/toast.dart';
import 'package:listener/screens/account.dart';
import 'package:listener/screens/discovery.dart';
import 'package:listener/screens/load_songs.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/providers/smart_contract_provider.dart';
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
  bool shouldProceed = false;

  late String nextPage;

  Future<String> _fetchPrefs(BuildContext context) async {
    nextPage = "/discovery";
    // await writeToFile("sc.toml",
    //     "making this toml file unreadbale so that initilizeSmartContractIfNotSet is always triggered and will contain what is set in asset's toml file"); //FIXME for development purposes only, remove this line
    await initilizeSmartContractIfNotSet();
    Either<MyError, SC> potentialScFromFile = await readSmartContractFromFile();
    if (potentialScFromFile.isRight) {
      String abi = await readAbiFromAssets();
      Credentials credentials =
          context.read<CredentialsProvider>().getCredentials()!;
      Either<MyError, SmartContract> potentialSc = await SmartContract.create(
          potentialScFromFile.right.nodeUrl,
          potentialScFromFile.right.hexAdress,
          potentialScFromFile.right.chainId,
          credentials);
      if (potentialSc.isRight) {
        SmartContract smartContract = potentialSc.right;
        context
            .read<SmartContractProvider>()
            .updateSmartContract(smartContract);
      } else {
        toast(potentialSc.left.message);
        nextPage = "/smart_contract_settings";
      }
    } else {
      toast(potentialScFromFile.left.message);
      nextPage = "/smart_contract_settings";
    }

    return nextPage;
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
