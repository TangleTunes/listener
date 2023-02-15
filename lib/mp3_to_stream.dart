import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> loadAudioFile(String path, int start, int end) async {
  ByteData data = await rootBundle.load(path);
  Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
  print("returning bytes of file $path from $start to $end");
  return byteList;
}

Future<int> getAudioFileSize(String path) async {
  ByteData data = await rootBundle.load(path);
  Uint8List byteList = data.buffer.asUint8List();
  return byteList.length;
}
