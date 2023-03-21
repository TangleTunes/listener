import 'dart:math';
import 'dart:core';

import 'package:listener/distributor_connection/distributer_contact.dart';

double weiToMiota(BigInt wei) {
  double miota = (wei ~/ BigInt.from(pow(10, 12))) /
      (BigInt.from(
          pow(10, 6))); //drop the last 12 zeroes and then divide by 1 million
  return miota;
}

double priceInMiotaPerMinute(BigInt wei, int seconds, int byteLength) {
  BigInt weiPerMinute =
      ((wei * BigInt.from(byteLength / chunkSize)) ~/ BigInt.from(seconds)) *
          BigInt.from(60);
  double miotaPerMinute = weiToMiota(weiPerMinute);
  return miotaPerMinute;
}
