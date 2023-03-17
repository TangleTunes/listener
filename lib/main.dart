import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:listener13/providers/balance_provider.dart';
import 'package:listener13/providers/current_song_provider.dart';
import 'package:listener13/providers/playback_provider.dart';
import 'package:listener13/screens/create_account.dart';
import 'package:listener13/screens/load_songs.dart';
import 'package:listener13/screens/smart_contract_settings.dart';
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
    context.read<SongListProvider>().setSongsList([
      Song(
          songName: "Spanish song",
          artist: "Gonzales",
          duration: 34,
          price: 4,
          byteSize: 45,
          songId: Uint8List(0))
    ]);

    return MaterialApp(
      initialRoute: "/load_credentials",
      routes: {
        '/load_credentials': (context) => LoadingCredentials(),
        '/discovery': (context) => DiscoveryPage(),
        '/unlock': (context) => UnlockPage(),
        '/load_smart_contract': (context) => LoadingSmartContractInfo(),
        '/couple_account': (context) => CoupleAccount(),
        '/account': (context) => AccountPage(tabSelected: 0),
        '/library': (context) => LibraryPage(),
        '/load_songs': (context) => LoadingSongs(),
        "/smart_contract_settings": (context) => SmartContractSettings(),
        "/create_account": (context) => RegisterPage(),
      },
    );
  }
}
