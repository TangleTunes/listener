// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener13/components/text_inputs.dart';
import 'package:listener13/theme/theme_constants.dart';

import 'couple_account.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                builder: (BuildContext context) => usernameTextInput(context)),

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
                builder: (BuildContext context) => passwordTextInput(context)),

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
                    repeatPasswordTextInput(context)),

            SizedBox(height: 25),
            //the register button, which redirects you to the discovery page iff you filled in all the boxes
            SizedBox(
                width: 372,
                height: 56,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: COLOR_TERTIARY),
                  onPressed: () {},
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
                      Navigator.pushNamed(
                        context,
                        "/couple",
                      );
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
