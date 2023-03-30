// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/account_created_provider.dart';
import 'package:listener/providers/current_song_provider.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/providers/username_provider.dart';
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

  _fetchPrefs(BuildContext context) async {
    if (context.read<SmartContractProvider>().getSmartContract() != null) {
      chainIdController.text = context
          .read<SmartContractProvider>()
          .getSmartContract()!
          .chainId
          .toString();
      contractAddrController.text = context
          .read<SmartContractProvider>()
          .getSmartContract()!
          .contractAddr
          .hex;
      rpcUrlController.text =
          context.read<SmartContractProvider>().getSmartContract()!.rpcUrl;
    }
  }

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Smart Contract Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.question_mark_rounded),
        mini: true,
        foregroundColor: COLOR_SECONDARY,
        backgroundColor: COLOR_TERTIARY,
        onPressed: () {
          goToPage(context, "/help_page");
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
              color: COLOR_SECONDARY,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Change details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
                        child: Text(
                          'RPC Url',
                          style: TextStyle(
                            fontSize: 16,
                            color: COLOR_PRIMARY,
                          ),
                        ),
                      ),

                      // TextFormField(
                      //     style: TextStyle(color: COLOR_SECONDARY),
                      //     cursorColor: COLOR_PRIMARY,
                      //     decoration: InputDecoration(
                      //       contentPadding:
                      //           EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                      //       errorStyle: TextStyle(
                      //         color: COLOR_TERTIARY,
                      //       ),
                      //       errorBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(color: COLOR_TERTIARY)),
                      //       focusedErrorBorder: OutlineInputBorder(
                      //         borderSide:
                      //             BorderSide(color: COLOR_TERTIARY, width: 1.5),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(color: COLOR_PRIMARY)),
                      //       focusedBorder: OutlineInputBorder(
                      //           borderSide: BorderSide(color: COLOR_PRIMARY)),
                      //     ),
                      //     controller: rpcUrlController,
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'Required';
                      //       }
                      //       return null;
                      //     }),

                      smartContractTextFormField(rpcUrlController),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 14, 0, 4),
                        child: Text(
                          'Smart Contract Address',
                          style: TextStyle(fontSize: 15, color: COLOR_PRIMARY),
                        ),
                      ),
                      // TextFormField(
                      //     decoration: InputDecoration(
                      //       labelText: 'Smart Contract Address',
                      //     ),
                      //     controller: contractAddrController,
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'Required';
                      //       }
                      //       return null;
                      //     }),
                      smartContractTextFormField(contractAddrController),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 14, 0, 4),
                        child: Text(
                          'Chain ID',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      TextFormField(
                          style:
                              TextStyle(color: COLOR_PRIMARY.withOpacity(0.6)),
                          cursorColor: COLOR_PRIMARY,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4),
                            errorStyle: TextStyle(
                              color: COLOR_TERTIARY,
                            ),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: COLOR_TERTIARY)),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: COLOR_TERTIARY, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: COLOR_PRIMARY)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: COLOR_PRIMARY)),
                          ),
                          keyboardType: TextInputType.number,
                          controller: chainIdController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              int? numValue = int.tryParse(value!);
                              if (numValue == null) {
                                return 'Must be a number';
                              } else {
                                return 'Required';
                              }
                            }
                            return null;
                          }),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: COLOR_TERTIARY,
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                Either<MyError, SmartContract>
                                    potentialSmartContract =
                                    await SmartContract.create(
                                        rpcUrlController.text,
                                        contractAddrController.text,
                                        int.parse(chainIdController.text),
                                        context
                                            .read<CredentialsProvider>()
                                            .getCredentials()!);

                                if (potentialSmartContract.isRight) {
                                  print("now trying to write to file");
                                  await setContractAdress(
                                      contractAddrController.text);
                                  await setChainId(
                                      int.parse(chainIdController.text));
                                  await setNodeUrl(rpcUrlController.text);
                                  context
                                      .read<BalanceProvider>()
                                      .setContractBalance(null);
                                  context
                                      .read<AccountCreatedProvider>()
                                      .setAccountCreated(false);
                                  context
                                      .read<SongListProvider>()
                                      .setSongsList(null);
                                  context
                                      .read<UsernameProvider>()
                                      .setUsername(null);
                                  context
                                      .read<CurrentSongProvider>()
                                      .setSong(null);
                                  goToPage(context, "/load_smart_contract");
                                } else {
                                  toast("Could not reach this smart contract");
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                              }
                            },
                            child: const Text('Confirm changes',
                                style: TextStyle(
                                    color: COLOR_SECONDARY, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget smartContractTextFormField(TextEditingController controller) {
    return TextFormField(
        style: TextStyle(
          color: COLOR_PRIMARY.withOpacity(0.6),
        ),
        cursorColor: COLOR_PRIMARY,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          errorStyle: TextStyle(
            color: COLOR_TERTIARY,
          ),
          errorBorder:
              OutlineInputBorder(borderSide: BorderSide(color: COLOR_TERTIARY)),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.5),
          ),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: COLOR_PRIMARY)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: COLOR_PRIMARY)),
        ),
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        });
  }
}
