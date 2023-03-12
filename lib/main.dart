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

  @override
  void initState() {
    super.initState();
    _playback = Playback();
    initilize();
  }

  void initilize() async {
    String privateKey = await unlockPrivateKey("password123");
    print("unlockPrivateKey $privateKey");
    ByteData byteData = await rootBundle.load(
        "assets/privatekey.json"); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    String loadJson = utf8.decode(byteData.buffer
        .asUint8List()); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    final decodedJson = jsonDecode(
        loadJson); //FIXME remove! (this line is temporary so that privatekey is not pushed to git)
    String pk = decodedJson[
        'privatekey']; //FIXME: replace pk with password set by user input!
    print("decodedjson $pk");
    setPrivateKey(pk, "password123");
    // String privateKey = await unlockPrivateKey("password123");
    // print("unlockPrivateKey $privateKey");
    ownCredentials = EthPrivateKey.fromHex(privateKey);

    EthereumAddress contractAddr =
        EthereumAddress.fromHex("0x8fA1fc1Eec824a36fD31497EAa8716Fc9C446d51");
    ByteData smartContractByteData =
        await rootBundle.load('assets/smartcontract.abi.json');
    String abiCode = utf8.decode(smartContractByteData.buffer.asUint8List());
    smartContract = SmartContract(
        "http://217.104.126.34:9090/chains/tst1pr2j82svscklywxj8gyk3dt5jz3vpxhnl48hh6h6rn0g8dfna0zsceya7up/evm",
        contractAddr,
        ownCredentials,
        abiCode);
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
