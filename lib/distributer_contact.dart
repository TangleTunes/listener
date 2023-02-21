import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class DistributorContact {
  int totalCost = 0;
  final _chunkSize = 32766;
  String songIdentifier;

  DistributorContact(this.songIdentifier) {}

  Future<int> giveMeFileSize() async {
    ByteData data = await rootBundle.load(songIdentifier);
    Uint8List byteList = data.buffer.asUint8List();
    return byteList.length;
  }

  Future<Uint8List> giveMeChunk(int chunk) async {
    const FILE_SIZE = 965229;
    var byteStart = chunk * _chunkSize;
    var byteEnd = byteStart + _chunkSize;

    totalCost++;
    // print('returning chunk number $chunk which is from $byteStart, total cost is $totalCost');
    if (byteStart + _chunkSize > FILE_SIZE) {
      return _loadAudioFile(songIdentifier, byteStart, FILE_SIZE);
    } else {
      return _loadAudioFile(songIdentifier, byteStart, byteEnd);
    }
  }

  Future<Uint8List> _loadAudioFile(String path, int start, int end) async {
    ByteData data = await rootBundle.load(path);
    // print('loadAudioFile $start $end');
    Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
    return byteList;
  }
}
