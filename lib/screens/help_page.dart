// ignore_for_file: prefer_const_constructors

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
          'Help page',
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
                width: 500,
                height: 1000,
                decoration: BoxDecoration(
                    color: COLOR_SECONDARY,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Text(
                  "Help",
                  style: TextStyle(color: COLOR_PRIMARY, fontSize: 20),
                ),
              ),
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
