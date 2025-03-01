// character_status.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gungangazi/core_services/token_service.dart';
import '../../dto/status/character_status_dto.dart';
import '../../repositories/status/character_repository.dart';

class CharacterStatus extends ChangeNotifier {
  final CharacterRepository repository; // ✅ CharacterRepository 추가

  // 상태 필드
  int water_level = 100;
  int meal_level = 100;
  int sleep_level = 100;

  /// ✅ 생성자에서 CharacterRepository 받기
  CharacterStatus({required this.repository});



  Future<void> loadStatus(BuildContext context) async {
    
    final statusData = await repository.loadStatusFromServer();
    if (statusData != null) {
      final status = StatusDto.fromJson(statusData);
      water_level = status.water_level;
      meal_level = status.meal_level;
      sleep_level = status.sleep_level;

      notifyListeners(); // UI 갱신
    }
  }

  Future<void> saveStatus() async {
    String? username = await TokenService().getUsername() ?? "defaultUser";
    final statusDto = StatusDto(
      username: username, // 수정 필요
      water_level: water_level,
      meal_level: meal_level,
      sleep_level: sleep_level,
    );
   await repository.saveStatusToServer(statusDto);
  }

  Future<void> updateStatus({
    required int newWaterLevel,
    required int newMealLevel,
    required int newSleepLevel,
  }) async {
    water_level = newWaterLevel;
    meal_level = newMealLevel;
    sleep_level = newSleepLevel;

    notifyListeners(); // UI 갱신
    await saveStatus(); // 변경 즉시 서버 저장
  }
}
