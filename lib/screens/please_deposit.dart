// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:listener/components/text_inputs.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';

import '../error_handling/app_error.dart';
import '../utils/price_conversions.dart';
import '../utils/toast.dart';

class PleaseDeposit extends StatefulWidget {
  const PleaseDeposit({Key? key}) : super(key: key);

  @override
  State<PleaseDeposit> createState() => _PleaseDepositState();
}

class _PleaseDepositState extends State<PleaseDeposit> {
  final _formKey = GlobalKey<FormState>();
  late String _publicKey;
  late double _walletBalance;

  void _fetchprefs() async {
    var apiUrl =
        context.read<SmartContractProvider>().getSmartContract()!.rpcUrl;

    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    var credentials = context.read<CredentialsProvider>().getCredentials()!;
    EtherAmount etherBalance = await ethClient.getBalance(credentials.address);
    _walletBalance = weiToMiota(etherBalance.getInWei);
    print(_walletBalance);
  }

  @override
  void initState() {
    _publicKey =
        context.read<CredentialsProvider>().getCredentials()!.address.hex;

    super.initState();
    _fetchprefs();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
        body: Center(
            child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //the logo of Tangle Tunes and Tangle Tunes text
                    Container(
                        height: 82,
                        width: 82,
                        child: Center(
                          child: Image.asset('assets/logo_tangletunes.png'),
                        )),
                    SizedBox(height: 5),
                    Text('Tangle Tunes',
                        style: GoogleFonts.francoisOne(
                            fontSize: 30, color: COLOR_SECONDARY)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: COLOR_SECONDARY,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                "Please charge money on your account",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: COLOR_PRIMARY,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Your public key: $_publicKey",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: COLOR_PRIMARY, fontSize: 15),
                              ),
                              Text("create money for debug purposes"),
                              InkWell(
                                onTap: () => launchUrl(
                                    Uri.parse(
                                        'http://tangletunes.com/debug/faucet/$_publicKey'),
                                    mode: LaunchMode.externalApplication),
                                child: Text(
                                  'http://tangletunes.com/debug/faucet/$_publicKey',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: COLOR_PRIMARY),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 25),

                    SizedBox(
                        width: 372,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: COLOR_TERTIARY),
                          onPressed: () async {
                            goToPage(context, "/provide_username");
                          },
                          child: Text('Done',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        )),
                  ],
                )))));
  }
}
