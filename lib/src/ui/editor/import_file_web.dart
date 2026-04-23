// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

Future<String?> pickImportFileText() async {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()..accept = '.dart,.txt';

  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.first.then((_) {
      completer.complete(reader.result as String?);
    });
    reader.readAsText(file);
  });

  input.click();
  return completer.future;
}
