// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener13/audio_player/playback.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:listener13/providers/playback_provider.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/utils/go_to_page.dart';
import 'package:provider/provider.dart';

import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../utils/toast.dart';
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
  String privateKey = "unlock to view";
  final passwordController = TextEditingController();
  late bool _privateKeyVisible = false;
  final _formKeyForPasswordForm = GlobalKey<FormState>();
  final _formKeyForPrivateKeyForm = GlobalKey<FormState>();
  int tabSelected;

  _AccountPageState(this.tabSelected);

  _fetchPrefs(BuildContext context) async {
    SmartContract sc =
        context.read<SmartContractProvider>().getSmartContract()!;
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
          goToPage(context, "/library");

          break;
        case 1:
          goToPage(context, "/discovery");
          break;
        case 2:
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
                      "Your public key ${context.watch<CredentialsProvider>().getCredentials()!.address}"),
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

                                        privateKey = potentialPrivateKey.right;
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
                  Text("Your private key: $privateKey"),
                  IconButton(
                    onPressed: _privateKeyVisible
                        ? () async {
                            await Clipboard.setData(
                                ClipboardData(text: privateKey));
                          }
                        : null,
                    icon: Icon(Icons.content_copy),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        goToPage(context, "/couple_account");
                      },
                      child: Text("Couple a different account")),
                  ElevatedButton(
                      onPressed: () {
                        goToPage(context, "/create_account");
                      },
                      child: Text("Create a new acount"))
                ])),
                Center(
                    child: Column(children: [
                  Text(
                      "Rpc Url: ${context.watch<SmartContractProvider>().getSmartContract()!.rpcUrl}"), //fixme null check
                  Text(
                      "Hex: ${context.watch<SmartContractProvider>().getSmartContract()!.contractAddr}"),
                  Text(
                      "Chain id: ${context.watch<SmartContractProvider>().getSmartContract()!.chainId}"),
                  ElevatedButton(
                      onPressed: () {
                        goToPage(context, "/smart_contract_settings");
                      },
                      child: Text("Change details"))
                ]))
              ],
            )));

    ;
  }
}
