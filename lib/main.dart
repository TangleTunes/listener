import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:listener13/user_settings/manage_account.dart';
import 'package:listener13/user_settings/manage_smart_contract_details.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:listener13/providers/credentials_provider.dart';
import 'package:listener13/providers/smart_contract_provider.dart';
import 'package:listener13/providers/song_list_provider.dart';
import 'package:listener13/screens/couple_account.dart';
import 'package:listener13/screens/discovery.dart';
import 'package:listener13/screens/library.dart';
import 'package:listener13/screens/load_credentials.dart';
import 'package:listener13/screens/load_smart_contract.dart';
import 'package:listener13/screens/account.dart';
import 'package:listener13/screens/unlock_account.dart';
import 'package:web3dart/web3dart.dart';
import 'package:provider/provider.dart';
import 'audio_player/playback.dart';
import 'distributor_connection/distributer_contact.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SongListProvider()),
        ChangeNotifierProvider(create: (_) => SmartContractProvider()),
        ChangeNotifierProvider(create: (_) => CredentialsProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<SongListProvider>().setSongsList([
      Song(songName: "Spanish song", artist: "Gonzales", duration: 34, price: 4)
    ]);

    return MaterialApp(
      initialRoute: "/load_credentials",
      routes: {
        '/load_credentials': (context) => SplashPageForLoadingPK(),
        '/discovery': (context) => DiscoveryPage(),
        '/unlock': (context) => UnlockAccount(),
        '/load_smart_contract': (context) => SplashForSCCheck(),
        '/couple': (context) => CoupleAccount(),
        '/account': (context) => AccountPage(),
        '/library': (context) => LibraryPage(),
      },
    );
  }
}
