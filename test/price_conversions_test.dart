import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:listener/utils/price_conversions.dart';

void main() {
  test('weiToMiota', () async {
    expect(
        1,
        weiToMiota(BigInt.from(
            1000000000000000000))); //assert that 1 miota is equal to 1E18 wei
    expect(
        1,
        weiToMiota(BigInt.from(
            1000000123456111215))); //assert that last 12 digits are dropped
  });

  test('miotaToWei', () async {
    expect(BigInt.from(3000000000000000000), miotaToWei(BigInt.from(3)));
  });

  test('priceInMiotaPerMinute', () async {
    BigInt price = BigInt.from(1000000000000000000); //1E18 wei, so 1 miota
    expect(
        1,
        priceInMiotaPerMinute(price, 60,
            32500)); //the song is one chunk and 60 seconds long, so the price is simply 1 miota
  });
}
