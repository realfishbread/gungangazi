import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  static final Map<String, MemoryImage> _compressedImages = {};

  /// 🔥 **사전 로딩: 모든 이미지 압축하여 캐싱**
  static Future<void> preloadImages(List<String> imagePaths) async {
    for (var imagePath in imagePaths) {
      if (!_compressedImages.containsKey(imagePath)) {
        print("🛠 이미지 사전 로딩 중: $imagePath"); // ✅ 사전 로딩 로그 추가
        _compressedImages[imagePath] = await _compressImage(imagePath);
      }
    }
  }

  /// 🔥 **개별 이미지 압축**
  static Future<MemoryImage> _compressImage(String assetPath) async {
    try {
      print("🔍 [DEBUG] 압축 시작: $assetPath"); // ✅ 로그 추가

      // 🚨 `rootBundle.load()` 실행 전, 파일이 존재하는지 확인
      ByteData byteData = await rootBundle.load(assetPath);
      if (byteData == null) {
        print("❌ [ERROR] 이미지 파일을 찾을 수 없음: $assetPath");
        return MemoryImage(Uint8List(0));
      }

      Uint8List imageBytes = byteData.buffer.asUint8List();
      print("✅ [SUCCESS] 원본 이미지 로드 완료: ${imageBytes.length} bytes");

      // 🚨 `compressWithList` 실행 전, 원본 데이터가 존재하는지 확인
      if (imageBytes.isEmpty) {
        print("❌ [ERROR] 원본 이미지 데이터가 비어 있음: $assetPath");
        return MemoryImage(Uint8List(0));
      }

      Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 60, // 압축 품질 (0~100)
      );

      print("✅ [SUCCESS] 이미지 압축 성공: ${compressedBytes.length} bytes");
      return MemoryImage(compressedBytes);
    } catch (e) {
      print("❌ [ERROR] 이미지 압축 실패: $assetPath → $e");
      return MemoryImage(Uint8List(0)); // 실패 시 빈 이미지 반환
    }
  }

  /// 🔥 **압축된 이미지 가져오기**
  static MemoryImage? getCompressedImage(String assetPath) {
    if (!_compressedImages.containsKey(assetPath)) {
      print("⚠️ [WARNING] 요청된 이미지가 압축되지 않음: $assetPath");
    }
    return _compressedImages[assetPath];
  }
}
