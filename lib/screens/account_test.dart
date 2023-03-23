// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listener/audio_player/playback.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/playback_provider.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';

import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../utils/toast.dart';
import '../providers/balance_provider.dart';
import '../providers/credentials_provider.dart';
import '../providers/song_list_provider.dart';
import '../theme/theme_constants.dart';
import '../utils/price_conversions.dart';

class AccountPageTest extends StatefulWidget {
  final int tabSelected;
  const AccountPageTest({required this.tabSelected, Key? key})
      : super(key: key);

  @override
  State<AccountPageTest> createState() => _AccountPageStateTest(tabSelected);
}

class _AccountPageStateTest extends State<AccountPageTest> {
  final rpcUrlController = TextEditingController();
  final contractAddrController = TextEditingController();
  final chainIdController = TextEditingController();
  String privateKey = "unlock to view";
  final passwordController = TextEditingController();
  final balanceController = TextEditingController();
  late bool _privateKeyVisible = false;
  final _formKeyForPasswordForm = GlobalKey<FormState>();
  final _formKeyForBalanceForm = GlobalKey<FormState>();
  int tabSelected;

  _AccountPageStateTest(this.tabSelected);

  Future<void> _fetchPrefs(BuildContext context) async {
    SmartContract sc =
        context.read<SmartContractProvider>().getSmartContract()!;
    Either<MyError, List<dynamic>> potentialBalance =
        await sc.users(sc.ownAddress.hex);
    if (potentialBalance.isRight) {
      BigInt balance = potentialBalance.right[4];
      print("your balance is $balance");
      context.read<BalanceProvider>().updateBalance(balance);
    } else {
      toast(potentialBalance.left.message);
    }
    return;
  }

  @override
  void initState() {
    _privateKeyVisible = false;

    super.initState();
    // _fetchPrefs(context); //running initialisation code; getting prefs etc.
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

  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          goToPage(context, "/discovery");
          break;
        case 1:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: tabSelected,
        child: Scaffold(
          //extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          //the Profile Appbar
          appBar: AppBar(
            centerTitle: true,
            title: Text('Profile',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 20,
            bottom: const TabBar(
              indicatorColor: COLOR_TERTIARY,
              //isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.account_circle)),
                Tab(icon: Icon(Icons.settings)),
                Tab(icon: Icon(Icons.heart_broken)),
              ],
            ),
          ),
          //the Bottom Navigation
          bottomNavigationBar: BottomNavigationBar(
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            iconSize: 38,
            backgroundColor: Color(0xFF091227),
            items: const <BottomNavigationBarItem>[              
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
          body: TabBarView(children: [
            //find a way to make it expand with overflowing on the sides
            SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: Container(
                            height: 220,
                            width: 200,
                            decoration: BoxDecoration(
                                color: COLOR_SECONDARY,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Balance",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: COLOR_PRIMARY)),
                                  Text(
                                      "${weiToMiota(context.watch<BalanceProvider>().getBalance())} MIOTA",
                                      style: TextStyle(color: COLOR_PRIMARY)),
                                  Form(
                                      key: _formKeyForBalanceForm,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            keyboardType: TextInputType.number,
                                            style:
                                                TextStyle(color: COLOR_PRIMARY),
                                            decoration: InputDecoration(
                                              labelText: 'Amount (in MIOTA)',
                                              labelStyle: TextStyle(
                                                  color: COLOR_PRIMARY),
                                            ),
                                            // The validator receives the text that the user has entered.
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Required';
                                              } else {
                                                BigInt? numValue =
                                                    BigInt.tryParse(value!);
                                                if (numValue == null ||
                                                    (numValue <=
                                                        BigInt.from(0))) {
                                                  return 'Must be a positive integer number';
                                                }
                                              }
                                              return null;
                                            },
                                            controller: balanceController,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // Validate returns true if the form is valid, or false otherwise.
                                                if (_formKeyForBalanceForm
                                                    .currentState!
                                                    .validate()) {
                                                  // If the form is valid, display a snackbar. In the real world,
                                                  // you'd often call a server or save the information in a database.
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Processing Data')),
                                                  );
                                                  SmartContract sc = context
                                                      .read<
                                                          SmartContractProvider>()
                                                      .getSmartContract()!;

                                                  ///temporary
                                                  Either<MyError, Null>
                                                      potentialDeposit =
                                                      await sc.deposit(miotaToWei(
                                                          BigInt.parse(
                                                              balanceController
                                                                  .text)));
                                                  if (potentialDeposit.isLeft) {
                                                    toast(
                                                        "Deposit transaction failed!");
                                                  } else {
                                                    toast(
                                                        "Deposit successful!");
                                                  }
                                                  Either<MyError, List<dynamic>>
                                                      potentialUserCall =
                                                      await sc.users((context
                                                              .read<
                                                                  CredentialsProvider>()
                                                              .getCredentials()!
                                                              .address)
                                                          .toString());
                                                  if (potentialUserCall
                                                      .isLeft) {
                                                    toast(
                                                        "Update balance failed!");
                                                  } else {
                                                    BigInt newBalance =
                                                        potentialUserCall
                                                            .right[4];
                                                    context
                                                        .read<BalanceProvider>()
                                                        .updateBalance(
                                                            newBalance);
                                                  }
                                                }
                                              },
                                              child: const Text('Deposit'),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            )),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      color: COLOR_SECONDARY,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Your public key",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: COLOR_PRIMARY)),
                                        Text(
                                          "${context.watch<CredentialsProvider>().getCredentials()!.address}",
                                          style: TextStyle(
                                              color: COLOR_PRIMARY,
                                              fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            print("button clicked");
                                            await Clipboard.setData(ClipboardData(
                                                text: context
                                                    .read<CredentialsProvider>()
                                                    .getCredentials()!
                                                    .address
                                                    .toString()));
                                          },
                                          icon: Icon(Icons.content_copy),
                                          color: COLOR_TERTIARY,
                                          tooltip: "Copy the public key",
                                          iconSize: 30,
                                        ),
                                      ],
                                    ),
                                  )),
                              SizedBox(height: 8),
                              Container(
                                  // height: 100,
                                  // width: 200,

                                  decoration: BoxDecoration(
                                      color: COLOR_SECONDARY,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      //mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Your private key",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: COLOR_PRIMARY)),
                                        Text(
                                          "$privateKey",
                                          style: TextStyle(
                                              color: COLOR_PRIMARY,
                                              fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Form(
                                          //the password form
                                          key: _formKeyForPasswordForm,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                style: TextStyle(
                                                    color: COLOR_PRIMARY),
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle: TextStyle(
                                                      color: COLOR_PRIMARY),
                                                ),
                                                // The validator receives the text that the user has entered.
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Required';
                                                  }
                                                  return null;
                                                },
                                                controller: passwordController,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16.0),
                                                child: ElevatedButton(
                                                  onPressed: !_privateKeyVisible
                                                      ? () async {
                                                          // Validate returns true if the form is valid, or false otherwise.
                                                          if (_formKeyForPasswordForm
                                                              .currentState!
                                                              .validate()) {
                                                            // If the form is valid, display a snackbar. In the real world,
                                                            // you'd often call a server or save the information in a database.
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Processing Data')),
                                                            );
                                                            Either<MyError,
                                                                    String>
                                                                potentialPrivateKey =
                                                                await unlockPrivateKey(
                                                                    passwordController
                                                                        .text);
                                                            if (potentialPrivateKey
                                                                .isRight) {
                                                              //Make private key visible since the pasword is correct
                                                              setState(() {
                                                                _privateKeyVisible =
                                                                    true;
                                                              });

                                                              privateKey =
                                                                  potentialPrivateKey
                                                                      .right;
                                                            } else {
                                                              //Display error message
                                                              toast(
                                                                  potentialPrivateKey
                                                                      .left
                                                                      .message);
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
                                        IconButton(
                                          onPressed: _privateKeyVisible
                                              ? () async {
                                                  await Clipboard.setData(
                                                      ClipboardData(
                                                          text: privateKey));
                                                }
                                              : null,
                                          icon: Icon(Icons.content_copy),
                                          color:
                                              COLOR_TERTIARY, //why is it not orange?
                                          iconSize: 30,
                                          tooltip: "Copy the private key",
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
            SingleChildScrollView(
                child: Column(children: [
              Text('hello', style: TextStyle(fontSize: 100)),
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
                "Rpc Url: ${context.watch<SmartContractProvider>().getSmartContract()!.rpcUrl}",
                style: TextStyle(color: COLOR_SECONDARY),
              ),
              Text(
                "Hex: ${context.watch<SmartContractProvider>().getSmartContract()!.contractAddr}",
                style: TextStyle(color: COLOR_SECONDARY),
              ),
              Text(
                "Chain id: ${context.watch<SmartContractProvider>().getSmartContract()!.chainId}",
                style: TextStyle(color: COLOR_SECONDARY),
              ),
              ElevatedButton(
                  onPressed: () {
                    goToPage(context, "/smart_contract_settings");
                  },
                  child: Text("Change details"))
            ]))
          ]),
        ));
  }
}
