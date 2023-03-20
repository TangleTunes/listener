// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../user_settings/manage_smart_contract_details.dart';
import '../utils/toast.dart';
import '../providers/balance_provider.dart';
import '../providers/credentials_provider.dart';
import '../providers/song_list_provider.dart';
import '../theme/theme_constants.dart';

class SmartContractSettings extends StatefulWidget {
  const SmartContractSettings({Key? key}) : super(key: key);

  @override
  State<SmartContractSettings> createState() => _SmartContractSettingsState();
}

class _SmartContractSettingsState extends State<SmartContractSettings> {
  final rpcUrlController = TextEditingController();
  final contractAddrController = TextEditingController();
  final chainIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _fetchPrefs(BuildContext context) async {}

  @override
  void initState() {
    super.initState();
    _fetchPrefs(context); //running initialisation code; getting prefs etc.
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    rpcUrlController.dispose();
    contractAddrController.dispose();
    chainIdController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(children: [
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
                decoration: InputDecoration(
                  labelText: 'RPCUrl',
                ),
                controller: rpcUrlController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                }),
            TextFormField(
                decoration: InputDecoration(
                  labelText: 'Smart Contract Address',
                ),
                controller: contractAddrController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                }),
            TextFormField(
                decoration: InputDecoration(
                  labelText: 'Chain ID',
                ),
                keyboardType: TextInputType.number,
                controller: chainIdController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    num? numValue = num.tryParse(value!);
                    if (numValue == null) {
                      return 'Must be a number';
                    } else {
                      return 'Required';
                    }
                  }
                  return null;
                }),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Either<MyError, SmartContract> potentialSmartContract =
                      await SmartContract.create(
                          rpcUrlController.text,
                          contractAddrController.text,
                          int.parse(chainIdController.text),
                          context
                              .read<CredentialsProvider>()
                              .getCredentials()!);

                  if (potentialSmartContract.isRight) {
                    print("now trying to write to file");
                    await setContractAdress(contractAddrController.text);
                    await setChainId(int.parse(chainIdController.text));
                    await setNodeUrl(rpcUrlController.text);
                    goToPage(context, "/load_smart_contract");
                  } else {
                    toast("Could not reach this smart contract");
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    ])));
  }
}
