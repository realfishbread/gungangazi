// lib/image_picker_mobile.dart
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImageMobile() async {
  final picker = ImagePicker();
  return await picker.pickImage(source: ImageSource.gallery);
}
