import 'package:flutter/material.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/helper_widgets.dart';

import '../theme/theme_constants.dart';

Widget makeLoadingScreen(BuildContext context, String loadingMsg,
    String nextRoute, bool shouldProceed) {
  return Scaffold(
      body: Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(loadingMsg, style: TextStyle(color: COLOR_SECONDARY)),
      shouldProceed
          ? ElevatedButton(
              onPressed: () {
                //move to next screen and pass the prefs if you want
                if (nextRoute == "pop") {
                  goToPreviousPage(context);
                } else {
                  goToPage(context, nextRoute);
                }
              },
              child: Text("Continue"),
            )
          : CircularProgressIndicator(), //show splash screen here instead of progress indicator
    ]),
  ));
}
