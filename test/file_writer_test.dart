// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:listener/user_settings/file_writer.dart';

String fakeApplicationDocumentsPath = Directory.current.path + "/test";

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return fakeApplicationDocumentsPath;
        default:
      }
    });
  });

  test('writeToFile', () async {
    print(fakeApplicationDocumentsPath);
    String text = "test";
    await writeToFile("test.txt", text); //writing to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/test.txt');
    String contents = await file.readAsString(); //reading
    expect(contents, text);
  });
}
