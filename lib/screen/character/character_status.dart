import '../../repositories/status/character_repository.dart';
import 'package:flutter/material.dart'; // ChangeNotifier를 위해 추가
import '../../dto/status/character_status_dto.dart';
import '../../core_services/token_service.dart';

class CharacterStatus extends ChangeNotifier { // ✅ ChangeNotifier 상속
  // ✅ 싱글톤 인스턴스
  static final CharacterStatus _instance = CharacterStatus._internal(CharacterRepository());

  // ✅ 팩토리 생성자로 싱글톤 유지
  factory CharacterStatus() => _instance;

  // ✅ 의존성 주입 가능하도록 변경
  final CharacterRepository _characterRepository;

  // ✅ private 생성자로 외부에서 직접 인스턴스화 방지
  CharacterStatus._internal(this._characterRepository);

  int waterLevel = 100;
  int mealLevel = 100;
  int sleepLevel = 100;

  Future<void> loadStatus() async {
    final statusData = await _characterRepository.loadStatusFromServer();
    if (statusData != null) {
      StatusDto status = StatusDto.fromJson(statusData);
      waterLevel = status.waterLevel;
      mealLevel = status.mealLevel;
      sleepLevel = status.sleepLevel;
      notifyListeners(); // ✅ UI 업데이트 트리거
    }
  }

  Future<void> saveStatus() async {
    String? username = await TokenService().getUsername() ?? "defaultUser";

    StatusDto statusDto = StatusDto(
      waterLevel: waterLevel,
      mealLevel: mealLevel,
      sleepLevel: sleepLevel,
      username: username,
    );
    await _characterRepository.saveStatusToServer(statusDto);
  }

  Future<void> updateStatus({
    required int newWaterLevel,
    required int newMealLevel,
    required int newSleepLevel,
  }) async {
    waterLevel = newWaterLevel;
    mealLevel = newMealLevel;
    sleepLevel = newSleepLevel;

    notifyListeners(); // ✅ UI 업데이트
    await saveStatus();
  }
}
