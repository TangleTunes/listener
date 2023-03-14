import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:listener13/account/account.dart';
import 'package:listener13/distributor_connection/smart_contract.dart';
import 'package:web3dart/web3dart.dart';
import 'audio_player/playback.dart';
import 'distributor_connection/distributer_contact.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Playback _playback;
  late Credentials ownCredentials;
  late SmartContract smartContract;
  var songsList;

  @override
  void initState() {
    super.initState();
    _playback = Playback();
    initilize();
  }

  void initilize() async {
    ByteData byteData = await rootBundle.load(
        "assets/privatekey.json"); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    String loadJson = utf8.decode(byteData.buffer
        .asUint8List()); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    final decodedJson = jsonDecode(
        loadJson); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    String pk = decodedJson[
        'privatekey']; //FIXME: replace pk with password set by user input!
    setPrivateKey(
        pk, "password123"); //FIXME replace password123 with user input
    String privateKey = await unlockPrivateKey(
        "password123"); //FIXME replace password123 with user input
    ownCredentials = EthPrivateKey.fromHex(privateKey);

    EthereumAddress contractAddr =
        EthereumAddress.fromHex("0xb5F7F76bbdE176AC0A45EA1125F17784d8247aF4");
    ByteData smartContractByteData =
        await rootBundle.load('assets/smartcontract.abi.json');
    String abiCode = utf8.decode(smartContractByteData.buffer.asUint8List());
    smartContract = SmartContract(
        "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm",
        contractAddr,
        ownCredentials,
        abiCode);
    songsList = smartContract.getSongs(0, 1).toString();
    print("My public key is ${ownCredentials.address}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(),
              Text(songsList.toString()),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  DistributorContact distributorContact = DistributorContact(
                      smartContract,
                      ownCredentials,
                      "0x74d0c7eb93c754318bca8174472a70038f751f2b",
                      "http://10.0.2.2:3000");
                  _playback.setAudio(
                      "51dba6a00c006f51b012f6e6c1516675ee4146e03628e3567980ed1c354441f2",
                      2034553,
                      distributorContact);
                },
                child: Text(
                    'Song 51dba6a00c006f51b012f6e6c1516675ee4146e03628e3567980ed1c354441f2'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  DistributorContact distributorContact = DistributorContact(
                      smartContract,
                      ownCredentials,
                      "0x74d0c7eb93c754318bca8174472a70038f751f2b",
                      "http://10.0.2.2:3000");
                  _playback.setAudio(
                      "0800000722040506080000072204050608000007220405060800000722040506",
                      2113939,
                      distributorContact);
                },
                child: Text(
                    'Song 0800000722040506080000072204050608000007220405060800000722040506'),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  DistributorContact distributorContact = DistributorContact(
                      smartContract,
                      ownCredentials,
                      "0x74d0c7eb93c754318bca8174472a70038f751f2b",
                      "http://10.0.2.2:3000");
                  _playback.setAudio(
                      "486df48c7468457fc8fbbdc0cd1ce036b2b21e2f093559be3c37fcb024c1facf",
                      2113939,
                      distributorContact);
                },
                child: Text(
                    'Song 486df48c7468457fc8fbbdc0cd1ce036b2b21e2f093559be3c37fcb024c1facf'),
              ),
              ValueListenableBuilder<ProgressBarState>(
                valueListenable: _playback.progressNotifier,
                builder: (_, value, __) {
                  return ProgressBar(
                    onSeek: _playback.seek,
                    progress: value.current,
                    buffered: value.buffered,
                    total: value.total,
                  );
                },
              ),
              ValueListenableBuilder<ButtonState>(
                valueListenable: _playback.buttonNotifier,
                builder: (_, value, __) {
                  switch (value) {
                    case ButtonState.loading:
                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        width: 32.0,
                        height: 32.0,
                        child: const CircularProgressIndicator(),
                      );
                    case ButtonState.paused:
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 32.0,
                        onPressed: _playback.play,
                      );
                    case ButtonState.playing:
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 32.0,
                        onPressed: _playback.pause,
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playback.dispose();
    super.dispose();
  }
}
