import 'dart:async';

import 'package:flutter/material.dart';

import '../core_services/dio_service.dart';
import '../core_services/token_service.dart';
import '../screen/character/character_image.dart';
import '../screen/character/character_status.dart';
import '../screen/character/character_status_service.dart';
import '../screen/character/popup_handler.dart';

class CharacterViewModel extends ChangeNotifier {
  final TokenService tokenService;
  final DioService dioService;
  CharacterStatus status;

  final now = DateTime.now();
  bool _isDisposed = false;

  int _previousWaterLevel = 100;
  int _previousMealLevel = 100;
  int _previousSleepLevel = 100;

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

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  CharacterViewModel({
    // 생성자 + 초기화 블록
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

    status.addListener(
        _onStatusChanged); //_onStatusChanged 만들어서 status가 변경될 때 애니메이션을 실행하겠다는 의도
  }

  Future<void> initialize() async {
    if (_isInitialized) return; // ✅ 제일 먼저 중복 방지

    await status.loadStatus();

    // ✅ 상태 기준 이전 값 세팅
    _previousWaterLevel = status.water_level;
    _previousMealLevel = status.meal_level;
    _previousSleepLevel = status.sleep_level;

    _currentBodyPartKey =
        CharacterStatusService.getBodyPartStatus(status, now); // 이미지 키 설정
    status.addListener(_onStatusChanged); // ✅ 먼저 리스너 등록

    _startAnimation(); // 그 다음에 애니메이션 시작

    _isInitialized = true;
  }

  void _onStatusChanged() {
    onStatusChanged(
      newWaterLevel: status.water_level,
      newMealLevel: status.meal_level,
      newSleepLevel: status.sleep_level,
    );
  }

  void onStatusChanged({
    required int newWaterLevel,
    required int newMealLevel,
    required int newSleepLevel,
  }) {
    if (newWaterLevel > _previousWaterLevel) {
      _previousWaterLevel = newWaterLevel;
      _resetAnimation();
      updateCharacterState();
    } else if (newMealLevel > _previousMealLevel) {
      _previousMealLevel = newMealLevel;
      _resetAnimation();
      updateCharacterState();
    } else if (newSleepLevel > _previousSleepLevel) {
      _previousSleepLevel = newSleepLevel;
      _resetAnimation();
      updateCharacterState();
    } else {
      print(
          "상태 변경 없음: 물: $newWaterLevel, 식사: $newMealLevel, 수면: $newSleepLevel");
    }
  }

  void updateStatus(CharacterStatus newStatus) {
    //새로운 상태 객체 주입 시 사용
    status.removeListener(_onStatusChanged); // 기존 리스너 제거
    status = newStatus;
    status.addListener(_onStatusChanged); // 새 상태에 리스너 다시 등록
  }

  void updateCharacterState() {
    final now = DateTime.now();
    final newKey =
        CharacterStatusService.getBodyPartStatus(status, now); // ✅ 새 키 계산

    if (_currentBodyPartKey != newKey) {
      _currentBodyPartKey = newKey;
      print("🔄 상태 업데이트로 이미지 키 변경됨: $_currentBodyPartKey");
      _resetAnimation(); // 키 바뀌었으니까 애니메이션도 초기화!
    }

    notifyListeners(); // 위에서 키 바뀐 경우에만 애니메이션 리셋하고, 항상 리빌드 알림
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

  void forceStopAnimation() {
    if (_isDisposed) return; // ✅ dispose 된 후에는 아무것도 하지 않기

    print('[🛑강제 종료] 애니메이션 강제 종료!');
    _timer?.cancel();
    _isAnimating = false;

    // ✅ 이 조건으로 중복 호출 방지
    final newKey = CharacterStatusService.getBodyPartStatus(status, now);
    if (newKey != _currentBodyPartKey) {
      _currentBodyPartKey = newKey;
    }

    _startAnimation(); // ✅ 새로운 상태로 기본 애니메이션 재시작
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
    if (_isAnimating) {
      forceStopAnimation();
    }

    print('[🎬시작] $bodyPart 애니메이션 시작!');
    _isAnimating = true;

    stopPeriodicStatusUpdate(); // 상태 갱신 멈춤

    _timer?.cancel(); // 혹시 이전 타이머가 남아있을 경우
    imageIndex.value = 0;
    _currentBodyPartKey = bodyPart;

    final animFrames = CharacterImagePaths.imagePathsByBodyPart[bodyPart] ??
        CharacterImagePaths.defaultImagePaths;

    _timer = Timer.periodic(frameDuration, (timer) {
      imageIndex.value = (imageIndex.value + 1) % animFrames.length;

      if (imageIndex.value == animFrames.length - 1) {
        timer.cancel();
        Future.delayed(Duration(milliseconds: delayMilliseconds), () {
          updateCharacterState(); // 상태 재계산
          _startAnimation(); // 기본 애니메이션
          print('[🧪복귀] 기본 애니메이션 시작!');
          _isAnimating = false;
        });
      }
    });
  }

  List<String> get currentImages =>
      CharacterImagePaths.imagePathsByBodyPart[_currentBodyPartKey] ??
      CharacterImagePaths.defaultImagePaths;

  @override
  void dispose() {
    _timer?.cancel();
    _statusUpdateTimer?.cancel();
    status.removeListener(_onStatusChanged);
    _isDisposed = true;
    super.dispose();
  }
}
