// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:provider/provider.dart';

import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../error_handling/toast.dart';
import '../providers/balance_provider.dart';
import '../providers/credentials_provider.dart';
import '../providers/song_list_provider.dart';
import '../theme/theme_constants.dart';

class AccountPage extends StatefulWidget {
  final int tabSelected;
  const AccountPage({required this.tabSelected, Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState(tabSelected);
}

class _AccountPageState extends State<AccountPage> {
  final rpcUrlController = TextEditingController();
  final contractAddrController = TextEditingController();
  final chainIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final privateKeyController = TextEditingController();
  final passwordController = TextEditingController();
  late bool _privateKeyVisible = false;
  final _formKeyForPasswordForm = GlobalKey<FormState>();
  final _formKeyForPrivateKeyForm = GlobalKey<FormState>();
  int tabSelected;

  _AccountPageState(this.tabSelected);

  _fetchPrefs(BuildContext context) async {
    SmartContract sc = context.read<SmartContractProvider>().getSmartContract();
    Either<MyError, List<dynamic>> potentialBalance =
        await sc.users(sc.ownAddress.hex);
    if (potentialBalance.isRight) {
      BigInt balance = potentialBalance.right[4];
      print("yur balance is $balance");
      context.read<BalanceProvider>().updateBalance(balance);
    } else {
      toast(potentialBalance.left.message);
    }
  }

  @override
  void initState() {
    _privateKeyVisible = false;

    super.initState();
    _fetchPrefs(context); //running initialisation code; getting prefs etc.
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    privateKeyController.dispose();
    rpcUrlController.dispose();
    contractAddrController.dispose();
    chainIdController.dispose();
    super.dispose();
  }

  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          break;
        case 1:
          Navigator.pushNamed(context, "/discovery");
          break;
        case 2:
          Navigator.pushNamed(context, "/account");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: tabSelected,
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.account_circle)),
                  Tab(icon: Icon(Icons.settings)),
                ],
              ),
            ),
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              iconSize: 38,
              backgroundColor: Color(0xFF091227),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: 'library',
                  icon: Icon(
                    Icons.favorite_border_outlined,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'search',
                  icon: Icon(
                    Icons.search,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'account',
                  icon: Icon(
                    Icons.account_circle,
                  ),
                ),
              ],
              currentIndex: _selectedIndex,
              selectedIconTheme: IconThemeData(color: COLOR_TERTIARY),
              unselectedIconTheme: IconThemeData(color: COLOR_SECONDARY),
              onTap: _onItemTapped,
            ),
            body: TabBarView(
              children: [
                Center(
                    child: Column(children: [
                  Text(
                      "Your public key ${context.watch<CredentialsProvider>().getCredentials().address}"),
                  Text(
                      "Your balance ${context.watch<BalanceProvider>().getBalance()}"),
                  Form(
                    //the password form
                    key: _formKeyForPasswordForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          controller: passwordController,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: !_privateKeyVisible
                                ? () async {
                                    // Validate returns true if the form is valid, or false otherwise.
                                    if (_formKeyForPasswordForm.currentState!
                                        .validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Processing Data')),
                                      );
                                      Either<MyError, String>
                                          potentialPrivateKey =
                                          await unlockPrivateKey(
                                              passwordController.text);
                                      if (potentialPrivateKey.isRight) {
                                        //Make private key visible since the pasword is correct
                                        setState(() {
                                          _privateKeyVisible = true;
                                        });

                                        privateKeyController.text =
                                            potentialPrivateKey.right;
                                      } else {
                                        //Display error message
                                        toast(potentialPrivateKey.left.message);
                                      }
                                    }
                                  }
                                : null,
                            child: const Text('Unlock'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKeyForPrivateKeyForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          enabled: _privateKeyVisible,
                          decoration: InputDecoration(
                            labelText: 'Private Key',
                          ),
                          controller: privateKeyController,

                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: _privateKeyVisible
                                ? () async {
                                    if (_formKeyForPrivateKeyForm.currentState!
                                        .validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      await setPrivateKey(
                                          privateKeyController.text,
                                          passwordController.text);
                                      context
                                          .read<CredentialsProvider>()
                                          .setOwnCredentials(
                                              privateKeyController.text);
                                      toast("Private key set!");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Processing Data')),
                                      );
                                    }
                                  }
                                : null,
                            child: const Text('Change private key'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
                Center(
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
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Smart Contract Address',
                          ),
                          controller: contractAddrController,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Chain ID',
                          ),
                          keyboardType: TextInputType.number,
                          controller: chainIdController,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, display a snackbar. In the real world,
                              // you'd often call a server or save the information in a database.
                              Either<MyError, SmartContract>
                                  potentialSmartContract =
                                  await SmartContract.create(
                                      rpcUrlController.text,
                                      contractAddrController.text,
                                      int.parse(chainIdController.text),
                                      context
                                          .read<CredentialsProvider>()
                                          .getCredentials());

                              if (potentialSmartContract.isRight) {
                                context
                                    .read<SmartContractProvider>()
                                    .updateSmartContract(
                                        potentialSmartContract.right);
                              } else {
                                toast("Could not reach this smart contract");
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                            }
                          },
                          child: const Text('Set Smart Contract Details'),
                        ),
                      ],
                    ),
                  ),
                ]))
              ],
            )));

    ;
  }
}
