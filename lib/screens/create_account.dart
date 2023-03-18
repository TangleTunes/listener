// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener13/components/text_inputs.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:listener13/theme/theme_constants.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/utils/go_to_page.dart';
import 'package:listener13/utils/toast.dart';
import 'package:provider/provider.dart';

import '../distributor_connection/smart_contract.dart';
import '../providers/credentials_provider.dart';
import 'couple_account.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    usernameController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
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
                style: GoogleFonts.francoisOne(
                    fontSize: 30, color: COLOR_SECONDARY)),
            SizedBox(height: 20),

            //The first text input box for your Username
            SizedBox(
              child: Container(
                width: 373,
                child: Text(
                  'Username*',
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
                    usernameTextInput(context, usernameController)),

            //The second text input box for your password
            SizedBox(height: 20),
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
                builder: (BuildContext context) =>
                    passwordTextInput(context, passwordController)),

            //The third text input box for repeating your password
            SizedBox(height: 20),
            SizedBox(
              child: Container(
                width: 373,
                child: Text(
                  'Repeat your password*',
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
                    repeatPasswordTextInput(context, repeatPasswordController)),

            SizedBox(height: 25),
            //the register button, which redirects you to the discovery page iff you filled in all the boxes
            SizedBox(
                width: 372,
                height: 56,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: COLOR_TERTIARY),
                  onPressed: () {
                    if (passwordController.text !=
                        repeatPasswordController.text) {
                      toast("Passwords don't match");
                    } else {
                      createAccount(usernameController.text,
                          passwordController.text, context);

                      goToPage(context, "/load_create_account");
                    }
                  },
                  child: Text('Create account',
                      style: GoogleFonts.poppins(fontSize: 16)),
                )),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Already have a wallet?',
                    style: TextStyle(
                      fontSize: 14,
                      color: COLOR_SECONDARY,
                    )),
                TextButton(
                    onPressed: () {
                      goToPage(context, "/couple_account");
                    },
                    child: Text('Couple it.',
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

// class SecondRoute extends StatelessWidget {
//   const SecondRoute({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Second Route'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Go back!'),
//         ),
//       ),
//     );
//   }
// }
