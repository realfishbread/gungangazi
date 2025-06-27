import 'dart:async';

import 'package:flutter/material.dart';

import '../core_services/dio_service.dart';
import '../core_services/token_service.dart';
import '../screen/character/character_image.dart';
import '../screen/character/character_status.dart';
import '../screen/character/character_status_service.dart';
import '../screen/character/popup_handler.dart';
import '../../repositories/status/character_repository.dart';

class CharacterViewModel extends ChangeNotifier {
  final TokenService tokenService;
  final DioService dioService;
  final CharacterStatus status;

  late CharacterStatusService characterStatusService;
  late PopupHandler popupHandler;

  final ValueNotifier<int> imageIndex = ValueNotifier<int>(0);
  final Duration frameDuration;
  Timer? _timer;
  Timer? _statusUpdateTimer;
  bool _isAnimating = false;

  final GlobalKey imageKey = GlobalKey();

  String _currentBodyPartKey = 'default';
  String get currentBodyPartKey => _currentBodyPartKey;

  CharacterViewModel({
    required this.tokenService,
    required this.dioService,
    required this.status, // ✅ 요거 빼먹어서 에러 난 거야
    this.frameDuration = const Duration(milliseconds: 300),
  }) {
    // 객체 초기화 명확히!
    characterStatusService = CharacterStatusService(); // ✅
    popupHandler = PopupHandler(
      characterViewModel: this,
      imageKey: imageKey, // ✅ 이거 꼭 추가!!
    );

    // 애니메이션과 상태 관리 초기화
    _startAnimation();
    status.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    updateCharacterState();
    _resetAnimation();
  }

  void updateCharacterState() {
    final now = DateTime.now();
    final rawStatus =
        CharacterStatusService.getBodyPartStatus(status, now); // ✅ 여긴 static
    _currentBodyPartKey = CharacterStatusService()
        .getTimeBasedOverride(rawStatus, now); // ✅ 인스턴스 메서드
    notifyListeners();
  }

  void _startAnimation() {
    _timer = Timer.periodic(frameDuration, (_) {
      final currentImages =
          CharacterImagePaths.imagePathsByBodyPart[_currentBodyPartKey] ??
              CharacterImagePaths.defaultImagePaths;
      imageIndex.value = (imageIndex.value + 1) % currentImages.length;
    });
  }

  void _resetAnimation() {
    imageIndex.value = 0;
    _timer?.cancel();
    _startAnimation();
  }

  void startPeriodicStatusUpdate() {
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      updateCharacterState();
    });
  }

  void stopPeriodicStatusUpdate() {
    _statusUpdateTimer?.cancel();
  }

  Future<void> triggerAnimation(String bodyPart,
      {int delayMilliseconds = 1000}) async {
    if (_isAnimating) return;
    _isAnimating = true;

    _timer?.cancel();
    imageIndex.value = 0;
    _currentBodyPartKey = bodyPart;

    final animFrames = CharacterImagePaths.imagePathsByBodyPart[bodyPart] ??
        CharacterImagePaths.defaultImagePaths;

    _timer = Timer.periodic(frameDuration, (timer) {
      imageIndex.value = (imageIndex.value + 1) % animFrames.length;

      if (imageIndex.value == animFrames.length - 1) {
        timer.cancel();
        Future.delayed(Duration(milliseconds: delayMilliseconds), () {
          _currentBodyPartKey = _calculateBodyPartKey();
          _startAnimation();
          _isAnimating = false;
        });
      }
    });
  }

  String _calculateBodyPartKey() {
    final water = status.water_level;
    final meal = status.meal_level;
    final sleep = status.sleep_level;
    final hour = DateTime.now().hour;
    final isNight = hour >= 22 || hour < 6;

    if (!isNight) {
      if (water <= 200 && meal <= 200 && sleep <= 200)
        return 'thirsty_and_hungry_dizzy';
      if (water <= 200 && meal <= 200) return 'thirsty_and_hungry';
      if (water <= 200 && sleep < 200) return 'thirsty_and_dizzy';
      if (meal <= 200 && sleep < 200) return 'hungry_and_dizzy';
      if (water <= 200) return 'thirsty';
      if (meal <= 200) return 'hungry';
      if (sleep < 200) return 'dizzy';
      return 'default';
    } else {
      if (water <= 200 && meal <= 200 && sleep <= 200) return '0amdizzy';
      if (water <= 200 && meal <= 200) return '0amddong';
      if (water <= 200 && sleep < 200) return '0amtired';
      if (meal <= 200 && sleep < 200) return '0amheadache';
      if (water <= 200) return '0amheadache';
      if (meal <= 200) return '0amstomach';
      if (sleep < 200) return '0amtired';
      return '0am';
    }
  }

  // 또는 CharacterViewModel.empty() 생성자도 만들어줘도 됨
  CharacterViewModel.empty()
      : status = CharacterStatus(CharacterRepository()),
        tokenService = TokenService(),
        dioService = DioService(),
        frameDuration = const Duration(milliseconds: 300) {
    characterStatusService = CharacterStatusService();
    popupHandler = PopupHandler(
      characterViewModel: this,
      imageKey: imageKey,
    );
  }

  List<String> get currentImages =>
      CharacterImagePaths.imagePathsByBodyPart[_currentBodyPartKey] ??
      CharacterImagePaths.defaultImagePaths;

  @override
  void dispose() {
    _timer?.cancel();
    status.removeListener(_onStatusChanged);
    _statusUpdateTimer?.cancel();
    super.dispose();
  }
}
