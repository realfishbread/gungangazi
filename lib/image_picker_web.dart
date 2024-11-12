// lib/image_picker_web.dart
import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:async';

Future<Uint8List?> pickImageWeb() async {
  final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()..accept = 'image/*';
  uploadInput.click();

  final completer = Completer<Uint8List?>();

  uploadInput.onChange.listen((event) {
    final file = uploadInput.files?.first;
    if (file != null) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        completer.complete(reader.result as Uint8List?);
      });
    }
  });

  return completer.future;
}
