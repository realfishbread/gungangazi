// lib/conditional_imports.dart
export 'image_picker_mobile.dart' if (dart.library.html) 'image_picker_web.dart';
