import 'package:flutter/material.dart';
import 'package:listener/utils/go_to_page.dart';
import 'package:listener/utils/helper_widgets.dart';

import '../theme/theme_constants.dart';

class LoadingScreen extends StatefulWidget {
  Future<String> Function(BuildContext) f;
  LoadingScreen(this.f) {}

  @override
  _LoadingScreenState createState() => _LoadingScreenState(f);
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool shouldProceed = false;
  Future<String> Function(BuildContext) f;
  _LoadingScreenState(this.f) {}
  @override
  Widget build(BuildContext context) {
    if (shouldProceed) {
      return SizedBox.shrink();
    } else {
      return Scaffold(
          body: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text("Loading"), CircularProgressIndicator()],
      )));
    }
  }

  // setShouldProceed(bool should) {
  //   setState() {
  //     shouldProceed = should;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String route = await f(context);
      setState(() {
        shouldProceed = true;
        goToPage(context, route);
      });
    });
  }

  // Future<Widget> _runsAfterBuild(
  //     bool shouldProceed, BuildContext context, String nextRoute) async {
  //   return await Future(() {
  //     if (shouldProceed) {
  //       return CircularProgressIndicator();
  //     } else {
  //       goToPage(context, nextRoute);
  //     }
  //   });
  // }

  // Widget makeLoadingScreen(BuildContext context, String loadingMsg,
  //     String nextRoute, bool shouldProceed) {
  //   // return await _runsAfterBuild(shouldProceed, context, nextRoute);
  //   return Scaffold(
  //       body: Center(
  //     child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  //       Text(loadingMsg, style: TextStyle(color: COLOR_SECONDARY)),

  //       shouldProceed
  //           ? ElevatedButton(
  //               onPressed: () {
  //                 //move to next screen and pass the prefs if you want
  //                 goToPage(context, nextRoute);
  //               },
  //               child: Text("Continue"),
  //             )
  //           : CircularProgressIndicator(), //show splash screen here instead of progress indicator
  //     ]),
  //   ));
  // }
}
