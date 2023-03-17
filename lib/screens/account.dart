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
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final privateKeyController = TextEditingController();
  final passwordController = TextEditingController();
  late bool _privateKeyVisible = false;
  final _formKeyForPasswordForm = GlobalKey<FormState>();
  final _formKeyForPrivateKeyForm = GlobalKey<FormState>();

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
    privateKeyController.dispose();
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
    return Scaffold(
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
        body: Center(
            child: Column(children: [
          Text("Your balance ${context.watch<BalanceProvider>().getBalance()}"),
          Text(
              "Your public key ${context.watch<CredentialsProvider>().getCredentials().address}"),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Processing Data')),
                              );
                              Either<MyError, String> potentialPrivateKey =
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
                    child: const Text('Submit'),
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
                              await setPrivateKey(privateKeyController.text,
                                  passwordController.text);
                              context
                                  .read<CredentialsProvider>()
                                  .setOwnCredentials(privateKeyController.text);
                              toast("Private key set!");
                              ScaffoldMessenger.of(context).showSnackBar(
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
          )
        ])));
  }
}
