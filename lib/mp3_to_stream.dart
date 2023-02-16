import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:typed_data';

//SMART CONTRACT
const chunkSize = 32000;
// Future<Uint8List> giveMeChunk(int chunk) async {
//   var byteStart = chunk * chunkSize;
//   var byteEnd = byteStart + chunkSize;
//   print('returning chunk number $chunk which is from $byteStart to $byteEnd');
//   return loadAudioFile('assets/1234.mp3', byteStart, byteEnd);
// }

Future<Uint8List> loadAudioFile(String path, int start, int end) async {
  ByteData data = await rootBundle.load(path);
  print('loadAudioFile $start $end');
  Uint8List byteList = data.buffer.asUint8List().sublist(start, end);
  return byteList;
}

Future<int> getAudioFileSize(String path) async {
  ByteData data = await rootBundle.load(path);
  Uint8List byteList = data.buffer.asUint8List();
  return byteList.length;
}

Stream<Uint8List> createStream(File file) async* {
  var length = await getAudioFileSize('assets/jelte.mp3');
  print('creating a stream $length');
  bool isFinished = false;
  int pos = 0;
  while (!isFinished) {
    print('inside while loop');
    late Uint8List chunk;

    if (pos + chunkSize > length) {
      Uint8List chunk = await loadAudioFile('assets/jelte.mp3', pos, length);
      print('last chunk: pos $pos length $length');
      // print('yielding $chunk');
      yield chunk;
    } else {
      Uint8List chunk =
          await loadAudioFile('assets/jelte.mp3', pos, pos + chunkSize);
      // print('yielding $chunk');
      yield chunk;
    }

    await Future.delayed(Duration(seconds: 1)); //sleep
    pos += chunkSize;
    if (pos > length) {
      isFinished = true;
    }
  }
}

Future<Uint8List> readFilePartially(File file, int offset, int length) async {
  final raf = await file.open(mode: FileMode.read);
  await raf.setPosition(offset); // set the file position to the desired offset
  final data = await raf.read(length); // read the specified number of bytes
  // print('file partially is is $data'); // process the read data
  await raf.close();
  return data;
}

void main() async {
  var myMusicStream = await createStream(File('jelte.mp3'));
  var i = 0;
  await for (var buf in myMusicStream) {
    print(i);
    i++;
    // print(buf);
  }
}
