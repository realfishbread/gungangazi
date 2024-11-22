import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:async';

Future<Uint8List?> pickImageWeb() async {
  try {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.style.display = 'none'; // 화면에 보이지 않게 처리
    html.document.body?.append(uploadInput); // DOM에 추가

    // 파일 선택 이벤트 대기
    final completer = Completer<Uint8List?>();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as Uint8List?);
        });
      } else {
        completer.complete(null);
      }
    });

    uploadInput.click(); // 파일 선택 창 열기
    final result = await completer.future;

    uploadInput.remove(); // DOM에서 제거
    return result;
  } catch (e) {
    print('Error picking image: $e');
    return null;
  }
}
