import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class DistributorContact {
  final _chunkSize = 32766;
  String songIdentifier;
  int cost = 0;
  late int FILE_SIZE;

  DistributorContact(this.songIdentifier) {
    initialize();
  }

  Future<int> giveMeFileSize() async {
    ByteData data = await rootBundle.load(songIdentifier);
    Uint8List byteList = data.buffer.asUint8List();
    return byteList.length;
  }

  void initialize() async {
    FILE_SIZE = await giveMeFileSize();
  }

  Future<Uint8List> giveMeChunk(int chunk) async {
    cost++;
    print('You have to pay $cost');
    var byteStart = chunk * _chunkSize;
    var byteEnd = byteStart + _chunkSize;
    if (byteStart + _chunkSize > FILE_SIZE) {
      return _loadAudioFile(songIdentifier, byteStart, FILE_SIZE);
    } else {
      return _loadAudioFile(songIdentifier, byteStart, byteEnd);
    }
  }

  Future<Uint8List> _loadAudioFile(String path, int start, int end) async {
    ByteData data = await rootBundle.load(path);
    Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
    return byteList;
  }
}
