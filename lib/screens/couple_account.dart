// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener/components/text_inputs.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';

import '../error_handling/app_error.dart';
import '../utils/toast.dart';

class CoupleAccount extends StatefulWidget {
  const CoupleAccount({Key? key}) : super(key: key);

  @override
  State<CoupleAccount> createState() => _CoupleAccountState();
}

class _CoupleAccountState extends State<CoupleAccount> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final privateKeyController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    repeatPasswordController.dispose();
    privateKeyController.dispose();
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

                    //The first text input box for your Username
                    SizedBox(
                      child: Container(
                        width: 373,
                        child: Text(
                          'Password*',
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

                    //The second text input box for your password
                    SizedBox(height: 20),
                    SizedBox(
                      child: Container(
                        width: 373,
                        child: Text(
                          'Repeat password*',
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
                            repeatPasswordController,
                            "Repeat your password",
                            true)),

                    //The third text input box for inserting your private key
                    SizedBox(height: 20),
                    SizedBox(
                      child: Container(
                        width: 373,
                        child: Text(
                          'Your private key*',
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
                            privateKeyController,
                            "Your private key",
                            false)),

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
                              if (passwordController.text !=
                                  repeatPasswordController.text) {
                                toast("Passwords don't match");
                              } else {
                                Either<MyError, Null> setPrivateKeyCall =
                                    await setPrivateKey(
                                        privateKeyController.text,
                                        passwordController.text,
                                        context);

                                if (setPrivateKeyCall.isRight) {
                                  Either<MyError, Null> setOwnCredentialsCall =
                                      context
                                          .read<CredentialsProvider>()
                                          .setOwnCredentials(
                                              privateKeyController.text);
                                  if (setOwnCredentialsCall.isRight) {
                                    goToPage(context, "/load_create_account");
                                  } else {
                                    toast(setOwnCredentialsCall.left.message);
                                  }
                                } else {
                                  toast(setPrivateKeyCall.left.message);
                                }
                              }
                            }
                          },
                          child: Text('Couple account',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        )),
                  ],
                )))));
  }
}
