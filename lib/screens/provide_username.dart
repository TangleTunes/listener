// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listener/components/text_inputs.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/providers/username_provider.dart';
import 'package:listener/theme/theme_constants.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:provider/provider.dart';

import '../error_handling/app_error.dart';
import '../utils/toast.dart';

class ProvideUsername extends StatefulWidget {
  const ProvideUsername({Key? key}) : super(key: key);

  @override
  State<ProvideUsername> createState() => _ProvideUsernameState();
}

class _ProvideUsernameState extends State<ProvideUsername> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
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
                    SizedBox(height: 20),
                    SizedBox(
                      child: Container(
                        width: 373,
                        child: Text(
                          'Give yourself a name*',
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
                            usernameController,
                            "Your username",
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
                              context
                                  .read<UsernameProvider>()
                                  .setUsername(usernameController.text);

                              goToPage(context, "/load_create_account");
                            }
                          },
                          child: Text('Continue',
                              style: GoogleFonts.poppins(fontSize: 16)),
                        )),
                  ],
                )))));
  }
}
