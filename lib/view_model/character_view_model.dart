import 'dart:async';

import 'package:flutter/material.dart';

import '../../repositories/status/character_repository.dart';
import '../core_services/dio_service.dart';
import '../core_services/token_service.dart';
import '../screen/character/character_image.dart';
import '../screen/character/character_status.dart';
import '../screen/character/character_status_service.dart';
import '../screen/character/popup_handler.dart';

class CharacterViewModel extends ChangeNotifier {
  final TokenService tokenService;
  final DioService dioService;
  final CharacterStatus status;

  late CharacterStatusService characterStatusService;
  late PopupHandler popupHandler;

  final ValueNotifier<int> imageIndex =
      ValueNotifier<int>(0); //이건 딱 하나의 값 (int) 에 변화가 있을 때만 감지함.
  final Duration frameDuration;
  Timer? _timer;
  Timer? _statusUpdateTimer;
  bool _isAnimating = false;

  final GlobalKey imageKey = GlobalKey();

  String _currentBodyPartKey = 'default';
  String get currentBodyPartKey => _currentBodyPartKey;

  CharacterViewModel({
    // 생성자 + 초기화 블록
    required this.tokenService,
    required this.dioService,
    required this.status, // ✅ 요거 빼먹어서 에러 난 거야
    this.frameDuration = const Duration(milliseconds: 500),
  }) {
    // 객체 초기화 명확히!
    characterStatusService = CharacterStatusService(); // ✅
    popupHandler = PopupHandler(
      characterViewModel: this,
      imageKey: imageKey, // ✅ 이거 꼭 추가!!
    );

    Future.microtask(() {
      // ✅ 초기에 상태를 미리 한번 계산해서 반영!
      _currentBodyPartKey = _calculateBodyPartKey();

      // 애니메이션과 상태 관리 초기화
      _startAnimation();
    });
    status.addListener(_onStatusChanged);
  }

  void _onStatusChanged() {
    //상태 업데이트 감지 & 반응
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
    //애니메이션 루프 타이머
    _timer?.cancel(); // ✅ 이전 타이머 제거
    final currentImages =
        CharacterImagePaths.imagePathsByBodyPart[_currentBodyPartKey] ??
            CharacterImagePaths.defaultImagePaths;

    print('🖼️ [$_currentBodyPartKey] 프레임 수: ${currentImages.length}');

    _timer = Timer.periodic(frameDuration, (_) {
      imageIndex.value = (imageIndex.value + 1) % currentImages.length;
    });
  }

  void _resetAnimation() {
    //프레임 인덱스 초기화 후, 다시 시작
    imageIndex.value = 0;
    _timer?.cancel();
    _startAnimation();
  }

  void startPeriodicStatusUpdate() {
    //자동 상태 주기적 갱신 타이머
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateCharacterState();
    });
  }

  void stopPeriodicStatusUpdate() {
    _statusUpdateTimer?.cancel();
  }

//터치 이벤트 등으로 강제로 애니메이션 바꾸는 함수
  Future<void> triggerAnimation(String bodyPart,
      {int delayMilliseconds = 1000}) async {
    if (_isAnimating) return;
    _isAnimating = true;

    stopPeriodicStatusUpdate(); // ⛔️ 상태 갱신 멈춤

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

    if (water == 0 && meal == 0 && sleep == 0) return 'loading'; // 🛑 이거 추가

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
