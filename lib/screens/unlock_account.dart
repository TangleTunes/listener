// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener/components/text_inputs.dart';
import 'package:listener/providers/account_created_provider.dart';
import 'package:listener/user_settings/file_writer.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/toast.dart';
import 'package:listener/user_settings/manage_smart_contract_details.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../error_handling/app_error.dart';
import '../user_settings/manage_account.dart';
import '../distributor_connection/smart_contract.dart';
import '../providers/smart_contract_provider.dart';
import 'couple_account.dart';

final LocalAuthentication auth = LocalAuthentication();

class UnlockPage extends StatefulWidget {
  const UnlockPage({Key? key}) : super(key: key);

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //extendBodyBehindAppBar: true,
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
                    SizedBox(height: 20),

                    //The text input box for your password to unlock your account
                    SizedBox(height: 20),
                    SizedBox(
                      child: Container(
                        width: 373,
                        child: Text(
                          'Your password*',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: COLOR_SECONDARY,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Builder(
                        builder: (BuildContext context) => createTextInput(
                            context,
                            passwordController,
                            "Your password",
                            true)),

                    SizedBox(height: 25),
                    //the register button, which redirects you to the discovery page iff you filled in all the boxes
                    SizedBox(
                        width: 372,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: COLOR_TERTIARY),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Either<MyError, String> potentialPrivateKey =
                                  await unlockPrivateKey(
                                      passwordController.text);
                              if (potentialPrivateKey.isRight) {
                                var setOwnCredentialsCall = context
                                    .read<CredentialsProvider>()
                                    .setOwnCredentials(
                                        potentialPrivateKey.right);
                                if (setOwnCredentialsCall.isRight) {
                                  context
                                      .read<AccountCreatedProvider>()
                                      .setAccountCreated(true);
                                  goToPage(context, "/discovery");
                                } else {
                                  toast(setOwnCredentialsCall.left.message);
                                }
                                // implement it to navigate to the discovery page
                              } else if (potentialPrivateKey.left.key ==
                                  AppError.IncorrectPrivateKeyPassword) {
                                toast(potentialPrivateKey.left.message);
                              } else if (potentialPrivateKey.left.key ==
                                  AppError
                                      .NonexistetOrCorruptedPrivateKeyFile) {
                                toast(potentialPrivateKey.left.message);
                                goToPage(context, "/couple_account");
                              }
                            }
                          },
                          child: Text('Unlock',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        )),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Use another account?',
                            style: TextStyle(
                              fontSize: 14,
                              color: COLOR_SECONDARY,
                            )),
                        TextButton(
                            onPressed: () async {
                              bool didAuthenticate = false;
                              if (await auth.isDeviceSupported()) {
                                didAuthenticate = await auth.authenticate(
                                    localizedReason:
                                        'Please authenticate to delete your private key from this phone.');
                              } else {
                                didAuthenticate = true;
                              }

                              if (didAuthenticate) {
                                await writeToFile("pk.json",
                                    "content"); //FIXME make more beautiful solution
                              }
                              goToPage(context, "/load_credentials");
                            },
                            child: Text('Delete private key.',
                                style: TextStyle(
                                  color: COLOR_SECONDARY,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                )))
                      ],
                    )
                  ],
                )))));
  }
}
