import 'dart:math';
import 'dart:core';

import 'package:listener/distributor_connection/distributer_contact.dart';

double weiToMiota(BigInt wei) {
  double miota = (wei ~/ BigInt.from(pow(10, 12))) /
      (BigInt.from(
          pow(10, 6))); //drop the last 12 zeroes and then divide by 1 million
  return miota;
}

BigInt miotaToWei(BigInt miota) {
  BigInt wei = miota * BigInt.from(pow(10, 18)); //multiply with 10^18
  return wei;
}

double priceInMiotaPerMinute(BigInt wei, int seconds, int byteLength) {
  BigInt totalprice = wei * BigInt.from(byteLength / chunkSize);
  print("total: $totalprice");

  BigInt pricePerSecond = totalprice ~/ BigInt.from(60);
  print("price per second:$pricePerSecond ");
  BigInt weiPerMinute = ((wei * BigInt.from(byteLength / chunkSize)) ~/
      BigInt.from(seconds / 60));
  double miotaPerMinute = weiToMiota(weiPerMinute);
  return miotaPerMinute;
}
