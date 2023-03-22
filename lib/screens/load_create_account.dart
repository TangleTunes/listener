import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener/components/loading_screen.dart';
import 'package:listener/distributor_connection/smart_contract.dart';

import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';
import '../providers/credentials_provider.dart';
import '../providers/smart_contract_provider.dart';

class LoadCreateAccount extends StatefulWidget {
  @override
  _LoadCreateAccountState createState() => _LoadCreateAccountState();
}

class _LoadCreateAccountState extends State<LoadCreateAccount> {
  Future<String> _fetchPrefs(BuildContext context) async {
    String nextPage = "/discovery";
    SmartContract sc =
        context.read<SmartContractProvider>().getSmartContract()!;
    EthereumAddress publicKey =
        context.read<CredentialsProvider>().getCredentials()!.address;

    Either<MyError, List<dynamic>> usersCall =
        await sc.users(publicKey.toString());
    bool userExists = false;
    if (usersCall.isRight) {
      userExists = usersCall.right[0];
      if (!userExists) {
        sc.createUser("name", "description"); //TODO put actual name of user
      } else {
        toast("Logged in as ${usersCall.right[1]}");
      }
    } else {
      toast(usersCall.left.message);
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
