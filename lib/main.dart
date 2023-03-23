import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:listener/providers/balance_provider.dart';
import 'package:listener/providers/current_song_provider.dart';
import 'package:listener/providers/playback_provider.dart';
import 'package:listener/screens/account_test.dart';
import 'package:listener/screens/create_account.dart';
import 'package:listener/screens/load_create_account.dart';
import 'package:listener/screens/load_songs.dart';
import 'package:listener/screens/smart_contract_settings.dart';
import 'package:listener/screens/start.dart';
import 'package:listener/user_settings/manage_account.dart';
import 'package:listener/user_settings/manage_smart_contract_details.dart';
import 'package:listener/distributor_connection/smart_contract.dart';
import 'package:listener/providers/credentials_provider.dart';
import 'package:listener/providers/smart_contract_provider.dart';
import 'package:listener/providers/song_list_provider.dart';
import 'package:listener/screens/couple_account.dart';
import 'package:listener/screens/discovery.dart';
import 'package:listener/screens/library.dart';
import 'package:listener/screens/load_credentials.dart';
import 'package:listener/screens/load_smart_contract.dart';
import 'package:listener/screens/account.dart';
import 'package:listener/screens/unlock_account.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import 'audio_player/playback.dart';
import 'distributor_connection/distributer_contact.dart';
import 'package:listener/theme/theme_constants.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongListProvider()),
        ChangeNotifierProvider(create: (_) => SmartContractProvider()),
        ChangeNotifierProvider(create: (_) => CredentialsProvider()),
        ChangeNotifierProvider(create: (_) => CurrentSongProvider()),
        ChangeNotifierProvider(create: (_) => PlaybackProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/start",
      routes: {
        '/start': (context) => StartPage(),
        '/load_credentials': (context) => LoadingCredentials(),
        '/discovery': (context) => DiscoveryPage(),
        '/unlock_account': (context) => UnlockPage(),
        '/load_smart_contract': (context) => LoadingSmartContractInfo(),
        '/couple_account': (context) => CoupleAccount(),
        //'/account': (context) => AccountPage(tabSelected: 0),
        '/account': (context) => AccountPageTest(tabSelected: 0),
        //'/library': (context) => LibraryPage(),
        '/load_songs': (context) => LoadingSongs(),
        "/smart_contract_settings": (context) => SmartContractSettings(),
        "/create_account": (context) => RegisterPage(),
        "/load_create_account": (context) => LoadCreateAccount(),
      },
      debugShowCheckedModeBanner: false,
      theme: themeData,
    );
  }
}
