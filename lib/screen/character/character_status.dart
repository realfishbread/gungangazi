import 'package:flutter/material.dart'; // ChangeNotifier를 위해 추가

import '../../core_services/token_service.dart';
import '../../dto/status/character_status_dto.dart';
import '../../repositories/status/character_repository.dart';

//캐릭터의 수치 상태 관리
class CharacterStatus extends ChangeNotifier {
  final CharacterRepository _characterRepository;
  int water_level = 100;
  int meal_level = 100;
  int sleep_level = 100;

  CharacterStatus(this._characterRepository); // 👈 의존성 주입

  Future<void> loadStatus() async {
    final statusData = await _characterRepository.loadStatusFromServer();
    if (statusData != null) {
      StatusDto status = StatusDto.fromJson(statusData);
      water_level = status.water_level;
      meal_level = status.meal_level;
      sleep_level = status.sleep_level;
      notifyListeners(); // ✅ UI 업데이트
    }
  }

  Future<void> saveStatus() async {
    String? username = await TokenService().getUsername() ?? "defaultUser";
    StatusDto statusDto = StatusDto(
      username: username,
      water_level: water_level,
      meal_level: meal_level,
      sleep_level: sleep_level,
    );
    await _characterRepository.saveStatusToServer(statusDto);
  }

  Future<void> updateStatus({
    required int newWaterLevel,
    required int newMealLevel,
    required int newSleepLevel,
  }) async {
    water_level = newWaterLevel;
    meal_level = newMealLevel;
    sleep_level = newSleepLevel;

    notifyListeners(); // 상태 업데이트 통지 (ViewModel이 여기 반응함)

    try {
      await saveStatus(); // 서버 저장 시도
    } catch (e) {
      debugPrint('❌ 서버 저장 실패: $e');
      // 👉 서버와 싱크 안 맞을 수 있음. 이건 네 앱 UX 컨셉에 따라 허용해도 됨.
    }
  }
}
