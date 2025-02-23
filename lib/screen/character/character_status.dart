import '../../repositories/status/character_repository.dart';
import 'PopupHandler.dart';

class CharacterStatus {
  int waterLevel = 100;
  int mealLevel = 100;
  int sleepLevel = 100;
  final CharacterRepository _characterRepository = CharacterRepository();

  // 상태를 서버에서 불러오기
  Future<void> loadStatus() async {
    await _characterRepository.loadStatusFromServer();
  }

  // 상태를 서버에 저장하기
  Future<void> saveStatus() async {
    await _characterRepository.saveStatusToServer();
  }

  // 현재 상태 업데이트
  void updateStatus({required int newWaterLevel, required int newMealLevel, required int newSleepLevel}) {
    waterLevel = newWaterLevel;
    mealLevel = newMealLevel;
    sleepLevel = newSleepLevel;
    saveStatus();
  }
}