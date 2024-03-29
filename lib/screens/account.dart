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
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../utils/toast.dart';
import '../providers/balance_provider.dart';
import '../providers/credentials_provider.dart';
import '../providers/song_list_provider.dart';
import '../theme/theme_constants.dart';
import '../utils/price_conversions.dart';

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
  String privateKey = "unlock to view";
  final passwordController = TextEditingController();
  final balanceController = TextEditingController();
  late bool _privateKeyVisible = false;
  final _formKeyForPasswordForm = GlobalKey<FormState>();
  final _formKeyForBalanceForm = GlobalKey<FormState>();
  bool _showPrivateKey = false;
  int tabSelected;

  _AccountPageState(this.tabSelected);

  Future<void> _fetchPrefs(BuildContext context) async {
    SmartContract sc =
        context.read<SmartContractProvider>().getSmartContract()!;
    Either<MyError, List<dynamic>> potentialBalance =
        await sc.users(sc.ownAddress.hex);
    if (potentialBalance.isRight) {
      BigInt balance = potentialBalance.right[4];
      context.read<BalanceProvider>().updateContractBalance(balance);
    } else {
      toast(potentialBalance.left.message);
    }
    String apiUrl = sc.rpcUrl;
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
    EthereumAddress myAddr =
        context.read<CredentialsProvider>().getCredentials()!.address;
    EtherAmount l2Balance = await ethClient.getBalance(myAddr);
    context.read<BalanceProvider>().updateL2BalanceInWei(l2Balance.getInWei);
    return;
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
      length: 2,
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
          //toolbarHeight: 20,
          bottom: const TabBar(
            indicatorColor: COLOR_TERTIARY,
            //isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.article)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
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
        body: TabBarView(
          children: [
            //find a way to make it expand with overflowing on the sides
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Column(
                            //mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2,
                                    maxWidth:
                                        MediaQuery.of(context).size.width / 2),
                                //width: 190,
                                //width: double.maxFinite,
                                decoration: BoxDecoration(
                                    color: COLOR_SECONDARY,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Balance",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: COLOR_PRIMARY)),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 4, 0, 4),
                                        child: context
                                                    .watch<BalanceProvider>()
                                                    .getContractBalance() ==
                                                null
                                            ? Text("Not fetched yet")
                                            : Text(
                                                "Contract: ${weiToMiota(context.watch<BalanceProvider>().getContractBalance()!).toStringAsPrecision(4)} MIOTA",
                                                
                                                style: TextStyle(
                                                    color: COLOR_PRIMARY,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            2, 4, 0, 4),
                                        child: context
                                                    .watch<BalanceProvider>()
                                                    .getL2BalanceInWei() ==
                                                null
                                            ? Text("Not fetched yet")
                                            : Text(
                                                "Layer 2: ${weiToMiota(context.watch<BalanceProvider>().getL2BalanceInWei()!).toStringAsPrecision(4)} MIOTA",
                                                style: TextStyle(
                                                    color: COLOR_PRIMARY,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      
                                      refreshBalanceButton(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              //Deposit money container
                              Container(
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width / 2),
                                // width: 190,
                                decoration: BoxDecoration(
                                    color: COLOR_SECONDARY,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Deposit/Withdraw",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: COLOR_PRIMARY)),
                                      Form(
                                          key: _formKeyForBalanceForm,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        2, 4, 0, 4),
                                                child: Text(
                                                  'Amount (in MIOTA):',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 180,
                                                child: TextFormField(
                                                  cursorColor: COLOR_PRIMARY,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: TextStyle(
                                                      color: COLOR_PRIMARY),
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 0,
                                                            horizontal: 4),
                                                    errorStyle: TextStyle(
                                                      color: COLOR_TERTIARY,
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                COLOR_TERTIARY)),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: COLOR_TERTIARY,
                                                          width: 1.5),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                COLOR_PRIMARY)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                COLOR_PRIMARY)),
                                                    // labelText: 'Amount (in MIOTA)',
                                                    // labelStyle: TextStyle(
                                                    //     color: COLOR_PRIMARY),
                                                  ),
                                                  // The validator receives the text that the user has entered.
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Required';
                                                    } else {
                                                      BigInt? numValue =
                                                          BigInt.tryParse(
                                                              value!);
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
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 4, 0, 0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              COLOR_TERTIARY),
                                                  onPressed: () async {
                                                    // Validate returns true if the form is valid, or false otherwise.
                                                    if (_formKeyForBalanceForm
                                                        .currentState!
                                                        .validate()) {
                                                      // If the form is valid, display a snackbar. In the real world,
                                                      // you'd often call a server or save the information in a database.
                                                      ScaffoldMessenger.of(
                                                              context)
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
                                                      if (potentialDeposit
                                                          .isLeft) {
                                                        toast(
                                                            "Deposit transaction failed!");
                                                      } else {
                                                        toast(
                                                            "Deposit successful!");
                                                      }
                                                      await _fetchPrefs(
                                                          context);
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Deposit',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 4),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              COLOR_TERTIARY),
                                                  onPressed: () async {
                                                    // Validate returns true if the form is valid, or false otherwise.
                                                    if (_formKeyForBalanceForm
                                                        .currentState!
                                                        .validate()) {
                                                      // If the form is valid, display a snackbar. In the real world,
                                                      // you'd often call a server or save the information in a database.
                                                      ScaffoldMessenger.of(
                                                              context)
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
                                                          potentialWithdraw =
                                                          await sc.withdraw(
                                                              miotaToWei(BigInt.parse(
                                                                  balanceController
                                                                      .text)));
                                                      if (potentialWithdraw
                                                          .isLeft) {
                                                        toast(
                                                            "Withdraw transaction failed!");
                                                      } else {
                                                        toast(
                                                            "Withdraw successful!");
                                                      }
                                                      await _fetchPrefs(
                                                          context);
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Withdraw',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
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
                                          copyPublicKeyWidget(),
                                        ],
                                      ),
                                    )),
                                SizedBox(height: 8),
                                Container(
                                    decoration: BoxDecoration(
                                        color: COLOR_SECONDARY,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
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
                                          Container(
                                            child: _showPrivateKey
                                                ? copyPrivateKeyWidget()
                                                : formUnlockPrivateKeyWidget(),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: COLOR_TERTIARY,
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                        onPressed: () {
                          goToPage(context, "/couple_account");
                        },
                        child: Text("Couple a different account",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: COLOR_TERTIARY,
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                          onPressed: () {
                            goToPage(context, "/create_account");
                          },
                          child: Text(
                            "Create a new acount",
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                  ),
                ],
              ),
            ),

            detailsWidget(),
          ],
        ),
      ),
    );
  }

  Widget refreshBalanceButton() {
    return IconButton(
      onPressed: () async {
        await _fetchPrefs(context);
        toast("Refreshed balance");
      },
      icon: Icon(Icons.refresh),
      color: COLOR_TERTIARY,
      tooltip: "Refresh",
      iconSize: 28,
    );
  }

  Widget copyPublicKeyWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
          child: Text(
            "${context.watch<CredentialsProvider>().getCredentials()!.address}",
            style: TextStyle(color: COLOR_PRIMARY, fontSize: 17),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: () async {
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
          iconSize: 28,
        ),
      ],
    );
  }

  Widget copyPrivateKeyWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
            child: Text(
              "$privateKey",
              style: TextStyle(color: COLOR_PRIMARY, fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _privateKeyVisible
                ? () async {
                    await Clipboard.setData(ClipboardData(text: privateKey));
                  }
                : null,
            icon: Icon(Icons.content_copy),
            color: COLOR_TERTIARY,
            iconSize: 28,
            tooltip: "Copy the private key",
          ),
        ],
      ),
    );
  }

  Widget formUnlockPrivateKeyWidget() {
    return Form(
      //the password form
      key: _formKeyForPasswordForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
            child: Text(
              'Password',
              style: TextStyle(fontSize: 15),
            ),
          ),
          TextFormField(
            style: TextStyle(color: COLOR_PRIMARY),
            cursorColor: COLOR_PRIMARY,
            obscureText: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
              errorStyle: TextStyle(
                color: COLOR_TERTIARY,
              ),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: COLOR_TERTIARY)),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: COLOR_TERTIARY, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: COLOR_PRIMARY)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: COLOR_PRIMARY)),
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
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: COLOR_TERTIARY),
              onPressed: !_privateKeyVisible
                  ? () async {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formKeyForPasswordForm.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                        Either<MyError, String> potentialPrivateKey =
                            await unlockPrivateKey(passwordController.text);
                        if (potentialPrivateKey.isRight) {
                          //Make private key visible since the pasword is correct
                          setState(() {
                            _privateKeyVisible = true;
                            _showPrivateKey = true;
                          });

                          privateKey = potentialPrivateKey.right;
                        } else {
                          //Display error message
                          toast(potentialPrivateKey.left.message);
                        }
                      }
                    }
                  : null,
              child: const Text(
                'Unlock',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detailsWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: COLOR_SECONDARY,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Smart contract details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: COLOR_PRIMARY,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Advanced use only, see help page for more info",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: COLOR_PRIMARY, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: COLOR_SECONDARY,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RPC URL",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: COLOR_PRIMARY)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
                      child: Text(
                          "${context.watch<SmartContractProvider>().getSmartContract()!.rpcUrl}",
                          style: TextStyle(color: COLOR_PRIMARY, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 190,
                        decoration: BoxDecoration(
                            color: COLOR_SECONDARY,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hex value",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: COLOR_PRIMARY)),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 4, 0, 4),
                                child: Text(
                                    "${context.watch<SmartContractProvider>().getSmartContract()!.contractAddr}",
                                    style: TextStyle(
                                        color: COLOR_PRIMARY, fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: COLOR_SECONDARY,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Chain ID",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: COLOR_PRIMARY),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 4, 0, 4),
                                  child: Text(
                                      "${context.watch<SmartContractProvider>().getSmartContract()!.contractAddr}",
                                      style: TextStyle(
                                          color: COLOR_PRIMARY, fontSize: 16)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: COLOR_TERTIARY,
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  onPressed: () {
                    goToPage(context, "/smart_contract_settings");
                  },
                  child: Text(
                    "Change details",
                    style: TextStyle(fontSize: 16),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
