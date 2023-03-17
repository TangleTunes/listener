// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener13/components/text_inputs.dart';
import 'package:listener13/error_handling/toast.dart';
import 'package:listener13/user_settings/manage_smart_contract_details.dart';
import 'package:listener13/providers/credentials_provider.dart';
import 'package:listener13/theme/theme_constants.dart';
import 'package:provider/provider.dart';

import '../error_handling/app_error.dart';
import '../user_settings/manage_account.dart';
import '../distributor_connection/smart_contract.dart';
import '../providers/smart_contract_provider.dart';
import 'couple_account.dart';

class UnlockPage extends StatefulWidget {
  const UnlockPage({Key? key}) : super(key: key);

  @override
  State<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends State<UnlockPage> {
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("building unlock account page");
    return Scaffold(
        //extendBodyBehindAppBar: true,
        body: Center(
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
            style:
                GoogleFonts.francoisOne(fontSize: 30, color: COLOR_SECONDARY)),
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
            builder: (BuildContext context) =>
                passwordTextInput(context, myController)),

        SizedBox(height: 25),
        //the register button, which redirects you to the discovery page iff you filled in all the boxes
        SizedBox(
            width: 372,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: COLOR_TERTIARY),
              onPressed: () async {
                Either<MyError, String> potentialPrivateKey =
                    await unlockPrivateKey(myController.text);
                if (potentialPrivateKey.isRight) {
                  context
                      .read<CredentialsProvider>()
                      .setOwnCredentials(potentialPrivateKey.right);
                  // implement it to navigate to the discovery page
                  Navigator.pushNamed(context, '/load_smart_contract');
                } else {
                  toast(potentialPrivateKey.left.message);
                }
              },
              child: Text('Unlock', style: GoogleFonts.poppins(fontSize: 16)),
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
                onPressed: () {
                  //TODO implement a pop up to delete your account
                },
                child: Text('Delete wallet.',
                    style: TextStyle(
                      color: COLOR_SECONDARY,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    )))
          ],
        )
      ],
    ))));
  }
}
