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
            toolbarHeight: 20,
            bottom: const TabBar(
              indicatorColor: COLOR_TERTIARY,
              //isScrollable: true,
              tabs: [
                Tab(icon: Icon(Icons.account_circle)),
                Tab(icon: Icon(Icons.settings)),
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
          body: TabBarView(children: [
            //find a way to make it expand with overflowing on the sides
            SingleChildScrollView(
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 220,
                        width: 200,
                        color: COLOR_SECONDARY,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Balance",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: COLOR_PRIMARY))
                            ],
                          ),
                        )),
                    Column(
                      children: [
                        Container(
                            height: 100,
                            width: 200,
                            color: COLOR_SECONDARY,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your public key",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: COLOR_PRIMARY)),
                                  Text(
                                    "${context.watch<CredentialsProvider>().getCredentials()!.address}",
                                    style: TextStyle(
                                        color: COLOR_PRIMARY, fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
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
                                    iconSize: 30,
                                    color: COLOR_TERTIARY,
                                  
                                  ),
                                ],
                              ),
                            )),
                        //SizedBox(height: 20),
                        Container(
                            height: 100,
                            width: 200,
                            color: COLOR_SECONDARY,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Your private key",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: COLOR_PRIMARY))
                                ],
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ],
            )),
            SingleChildScrollView(
              child: Text('hello', style: TextStyle(fontSize: 100)),
            )
          ]),
        ));
  }
}
