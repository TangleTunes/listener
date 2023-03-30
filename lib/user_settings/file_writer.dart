import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> writeToFile(String filename, String content) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  if (await file.exists()) {
    await file.create();
  }
  print("$filename now contains $content");
  await file.writeAsString(content);
}
