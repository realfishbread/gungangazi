import 'dart:async';

import 'package:flutter/material.dart';

import '../screen/character/character_image.dart';
import '../screen/character/character_status.dart';

//캐릭터 상태에 따라 이미지 상태 결정

class PopupHandlerViewModel extends ChangeNotifier {
  final CharacterStatus status;
  String _currentBodyPartKey = 'default';
  String get currentBodyPartKey => _currentBodyPartKey;

  final ValueNotifier<int> imageIndex = ValueNotifier<int>(0);
  final Duration frameDuration;
  Timer? _timer;

  PopupHandlerViewModel({
    required this.status,
    this.frameDuration = const Duration(milliseconds: 300),
  }) {
    _startAnimation();
    status.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    updateCharacterState();
    _resetAnimation();
  }

  String _calculateBodyPartKey() {
    final water = status.water_level;
    final meal = status.meal_level;
    final sleep = status.sleep_level;
    final now = DateTime.now();
    final hour = now.hour;
    final isNight = hour >= 22 || hour < 6;

    if (!isNight) {
      if (water <= 200 && meal <= 200 && sleep <= 200)
        return 'thirsty_and_hungry_dizzy';
      if (water <= 200 && meal <= 200 && sleep >= 200)
        return 'thirsty_and_hungry';
      if (water <= 200 && meal > 200 && sleep < 200) return 'thirsty_and_dizzy';
      if (water > 200 && meal <= 200 && sleep < 200) return 'hungry_and_dizzy';
      if (water <= 200 && meal > 200 && sleep >= 200) return 'thirsty';
      if (water > 200 && meal <= 200 && sleep >= 200) return 'hungry';
      if (water > 200 && meal > 200 && sleep < 200) return 'dizzy';
      return _statusFromTime(now); // 기본 fallback
    } else {
      if (water <= 200 && meal <= 200 && sleep <= 200) return '0amdizzy';
      if (water <= 200 && meal <= 200 && sleep >= 200) return '0amddong';
      if (water <= 200 && meal > 200 && sleep < 200) return '0amtired';
      if (water > 200 && meal <= 200 && sleep < 200) return '0amheadache';
      if (water <= 200 && meal > 200 && sleep >= 200) return '0amheadache';
      if (water > 200 && meal <= 200 && sleep >= 200) return '0amstomach';
      if (water > 200 && meal > 200 && sleep < 200) return '0amtired';
      return _statusFromTime(now);
    }
  }

  String _statusFromTime(DateTime now) {
    final hour = now.hour;
    final isNight = hour >= 22 || hour < 6;

    if (!isNight) return 'default';

    // 상태별로 야간 버전 매핑
    switch (_currentBodyPartKey) {
      case 'thirsty_and_hungry_dizzy':
        return '0amdizzy';
      case 'thirsty_and_hungry':
        return '0amddong';
      case 'thirsty_and_dizzy':
      case 'dizzy':
        return '0amtired';
      case 'thirsty':
      case 'hungry':
        return '0amstomach';
      default:
        return '0am'; // 기본 야간 상태
    }
  }

  

  List<String> get currentImages =>
      CharacterImagePaths.imagePathsByBodyPart[_currentBodyPartKey] ??
      CharacterImagePaths.defaultImagePaths;

  void updateCharacterState() {
    _currentBodyPartKey = _calculateBodyPartKey();
    notifyListeners();
  }

  void _startAnimation() {
    _timer = Timer.periodic(frameDuration, (_) {
      imageIndex.value = (imageIndex.value + 1) % currentImages.length;
    });
  }

  void _resetAnimation() {
    imageIndex.value = 0;
    _timer?.cancel();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    status.removeListener(_onStatusChanged);
    super.dispose();
  }
}
