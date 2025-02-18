import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static final Map<String, MemoryImage> _compressedImages = {};

  /// 이미지 압축 및 저장
  static Future<void> preloadImages(List<String> imagePaths) async {
    for (var imagePath in imagePaths) {
      if (!_compressedImages.containsKey(imagePath)) {
        _compressedImages[imagePath] = await _compressImage(imagePath);
      }
    }
  }

  /// 개별 이미지 압축
  static Future<MemoryImage> _compressImage(String assetPath) async {
    try {
      ByteData byteData = await rootBundle.load(assetPath);
      Uint8List imageBytes = byteData.buffer.asUint8List();

      Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 60, // 압축 품질 (0~100)
      );

      return MemoryImage(compressedBytes);
    } catch (e) {
      print("❌ 이미지 압축 실패: $e");
      return MemoryImage(Uint8List(0)); // 실패 시 빈 이미지 반환
    }
  }
//압축된 이미지 반환
  static MemoryImage? getCompressedImage(String assetPath) {
    return _compressedImages[assetPath];
  }
}
