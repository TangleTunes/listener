// ignore_for_file: prefer_const_constructors

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Components/text_inputs.dart';
import '../error_handling/app_error.dart';
import '../user_settings/manage_smart_contract_details.dart';
import '../utils/toast.dart';
import '../providers/balance_provider.dart';
import '../providers/credentials_provider.dart';
import '../providers/song_list_provider.dart';
import '../theme/theme_constants.dart';

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

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Help',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                      color: COLOR_SECONDARY,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Overview\n', style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "This TangleTunes app lets you listen to music and make you pay for only the portion of the song you are loading. So if you listen to half the song only, you will only pay for half the song. Your payment is almost entirely received by the rightholder (except a small distribution fee) and not by any external party.\n\n"),
                          TextSpan(
                              text: "How do I sign in?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  """First you need to create an account. There are 2 ways you can do this. 
   1) If you do not have a cryptocurrency wallet yet, you can use the ‘Create Account’ option. You will then be asked to put some money on your account in order to complete the process. For how to do that, scroll to “How do I get money?”
   2) If you already have a wallet, you can import your wallet private key through the ‘Couple Account’ option.\n\n"""),
                          TextSpan(
                              text: "How do I listen to music?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  """After you have signed in, you have the option to deposit money from your wallet to your TangleTunes account. Scroll to "What does deposit mean?" to find out how to do that. Once you have a sufficient balance, you can start listening to music by selecting a song and playing it.\n\n"""),
                          TextSpan(
                              text: "My music stopped playing. Why?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  """It could be that your phone has limited or no internet connection.\n"""),
                          TextSpan(
                              text:
                                  "It could also be that your contract balance is not sufficient. To change that, go to "),
                          WidgetSpan(
                              child: Icon(
                            Icons.account_circle,
                            color: COLOR_PRIMARY,
                            size: 20,
                          )),
                          TextSpan(
                              text:
                                  """ and deposit. In order to deposit you need ledger 2 funds. Scroll to “How do I get money?” to see how to do that."""),
                          context
                                      .read<SmartContractProvider>()
                                      .getSmartContract() !=
                                  null
                              ? TextSpan(
                                  text:
                                      "\nIn rare cases where transactions fail you can try resetting the nonce and clicking on a song again:\n")
                              : WidgetSpan(child: SizedBox.shrink()),
                          context
                                      .read<SmartContractProvider>()
                                      .getSmartContract() !=
                                  null
                              ? WidgetSpan(
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: COLOR_TERTIARY,
                                          padding:
                                              EdgeInsets.fromLTRB(5, 5, 5, 5)),
                                      onPressed: () async {
                                        Either<MyError, Null> updateNonceCall =
                                            await context
                                                .read<SmartContractProvider>()
                                                .getSmartContract()!
                                                .updateNonce();
                                        if (updateNonceCall.isRight) {
                                          toast("Updated the nonce");
                                        } else {
                                          toast(updateNonceCall.left.message);
                                        }
                                      },
                                      child: Text("Update nonce")))
                              : WidgetSpan(child: SizedBox.shrink()),
                          TextSpan(text: "\n\n"),
                          TextSpan(
                              text: "What does deposit mean?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "Depositing transfers money from your wallet to your TangleTunes account. Therefore you need to have enough currency in your wallet in order to be able to deposit.\n\n"),
                          TextSpan(
                              text: "What does withdraw mean?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "Withdrawing transfers money from TangleTunes account to your wallet. Therefore you need to have enough currency in your TangleTunes account to be able to withdraw.\n\n"),
                          TextSpan(
                              text: "What is a wallet?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "Wallets store cryptocurrencies such as MIOTA which is used on the TangleTunes network. There are different ways to get a wallet. The ‘Create Account’ option generates a new wallet for you. If you already have one you can import it through the ‘Couple Account’ option.\n\n"),
                          TextSpan(
                              text: "How do I get money?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "You pay in a cryptocurrency called MIOTA which you can obtain at a cryptocurrency exchange online. Then you have to send this MIOTA from the exchange to your wallet by specifying your public key as the recipient address. Your public key will be shown on screen when creating an account and you have no money. At a later point, you may find your public key on the "),
                          WidgetSpan(
                              child: Icon(
                            Icons.account_circle,
                            color: COLOR_PRIMARY,
                            size: 20,
                          )),
                          TextSpan(
                              text:
                                  """ page. This is also where your new balance will show up under "Ledger 2". \n\n"""),
                          TextSpan(
                              text: "What does public and private key mean?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "The public key is the address that is used when sending or receiving transactions. The private key is used to import an existing wallet. You should never share your private key with someone. You can find your public and private key on the "),
                          WidgetSpan(
                              child: Icon(
                            Icons.account_circle,
                            color: COLOR_PRIMARY,
                            size: 20,
                          )),
                          TextSpan(text: " page.\n\n"),
                          TextSpan(
                              text: "What are smart contract details?\n",
                              style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  "If you are asked to provide smart contract details, either your device has limited internet access, or you should look on "),
                          WidgetSpan(
                            child: InkWell(
                              onTap: () => launchUrl(
                                  Uri.parse(
                                      'http://tangletunes.com/smart-contract-information'),
                                  mode: LaunchMode.externalApplication),
                              child: Text(
                                'http://tangletunes.com/smart-contract-information',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: COLOR_PRIMARY),
                              ),
                            ),
                          ),
                          TextSpan(
                              text:
                                  " for the most up to date details and make sure to enter them into the app.\n\n"),
                          TextSpan(text: "About\n", style: BOLD_TEXT_STYLE),
                          TextSpan(
                              text:
                                  """This app is the listening client on the Tangle Tunes p2p network. \nFind the source code at: """),
                          WidgetSpan(
                            child: InkWell(
                              onTap: () => launchUrl(
                                  Uri.parse(
                                      'https://github.com/TangleTunes/listener'),
                                  mode: LaunchMode.externalApplication),
                              child: Text(
                                'https://github.com/TangleTunes/listener',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: COLOR_PRIMARY),
                              ),
                            ),
                          ),
                          TextSpan(
                              text: ".\nConsider becoming a distributor: \n"),
                          WidgetSpan(
                            child: InkWell(
                              onTap: () => launchUrl(
                                  Uri.parse(
                                      'https://github.com/TangleTunes/distributing_client'),
                                  mode: LaunchMode.externalApplication),
                              child: Text(
                                'https://github.com/TangleTunes/distributing_client',
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: COLOR_PRIMARY),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

@override
void initState() {
  initState(); //running initialisation code; getting prefs etc.
}
