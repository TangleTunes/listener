import 'dart:typed_data';

import 'package:listener13/distributor_connection/distributer_contact.dart';

void main() async {
  DistributorContact d = DistributorContact(
      "0800000722040506080000072204050608000007220405060800000722040506");
  await d.initialize();
  DistributorContact d2 = DistributorContact(
      "0800000722040506080000072204050608000007220405060800000722040506");
  await d2.initialize();
  print("initialized");
  List<Uint8List> song = [];
  // for (int i = 0; i < 20; i++) {
  //   Uint8List returnedChunk = await d.requestChunk(i);
  //   song.add(returnedChunk);
  //   print("recieved chunk $i");
  // }
  Uint8List returnedChunk = await d.giveMeChunk(0);
  Uint8List returnedChunk1 = await d.giveMeChunk(1);

  print("Song decoding finished ");
}
