import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

Future<Uint8List> loadAudioFile(String path) async {
  ByteData data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}
