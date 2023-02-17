import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:listener13/distributer_contact.dart';

import 'mp3_to_stream.dart';

class MyCustomSource extends StreamAudioSource {
  late String pathName;
  late DistributorContact distributorContact;

  MyCustomSource(this.pathName) {
    distributorContact = DistributorContact(pathName);
  }

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    print('.request method called with $start and $end');
    int fileSize = await distributorContact.giveMeFileSize();
    start ??= 0;
    end ??= fileSize;
    ChunkStream chunkStream =
        ChunkStream(distributorContact, distributorContact.songIdentifier);
    Stream<Uint8List> stream =
        chunkStream.createStream(start).asBroadcastStream();
    return StreamAudioResponse(
      sourceLength: fileSize,
      contentLength: end - start,
      offset: start,
      stream: stream,
      contentType: 'audio/mpeg',
    );
  }
}
