import 'character_status.dart';


// 캐릭터 상태 수치를 기반으로 어떤 상태(bodyPartKey)인지 판단
class CharacterStatusService {
  static String getBodyPartStatus(
      CharacterStatus characterStatus, DateTime now) {
    int hour = now.hour;
    bool isNight = (hour >= 22 || hour < 6);

    if (!isNight) {
      if (characterStatus.water_level <= 200 &&
          characterStatus.meal_level <= 200 &&
          characterStatus.sleep_level <= 200) {
        return 'thirsty_and_hungry_dizzy';
      }
    } else if (characterStatus.water_level <= 200 &&
        characterStatus.meal_level <= 200 &&
        characterStatus.sleep_level >= 200) {
      return 'thirsty_and_hungry';
    } else if (characterStatus.water_level <= 200 &&
        characterStatus.meal_level > 200 &&
        characterStatus.sleep_level < 200) {
      return 'thirsty_and_dizzy';
    } else if (characterStatus.water_level > 200 &&
        characterStatus.meal_level <= 200 &&
        characterStatus.sleep_level < 200) {
      return 'hungry_and_dizzy';
    } else if (characterStatus.water_level <= 200 &&
        characterStatus.meal_level > 200 &&
        characterStatus.sleep_level >= 200) {
      return 'thirsty';
    } else if (characterStatus.water_level > 200 &&
        characterStatus.meal_level <= 200 &&
        characterStatus.sleep_level >= 200) {
      return 'hungry';
    } else if (characterStatus.water_level > 200 &&
        characterStatus.meal_level > 200 &&
        characterStatus.sleep_level < 200) {
      return 'dizzy';
    } else if (isNight) {
      if (characterStatus.water_level <= 200 &&
          characterStatus.meal_level <= 200 &&
          characterStatus.sleep_level <= 200) {
        return '0amdizzy';
      } else if (characterStatus.water_level <= 200 &&
          characterStatus.meal_level <= 200 &&
          characterStatus.sleep_level >= 200) {
        return '0amddong';
      } else if (characterStatus.water_level <= 200 &&
          characterStatus.meal_level > 200 &&
          characterStatus.sleep_level < 200) {
        return '0amtired';
      } else if (characterStatus.water_level > 200 &&
          characterStatus.meal_level <= 200 &&
          characterStatus.sleep_level < 200) {
        return '0amheadache';
      } else if (characterStatus.water_level <= 200 &&
          characterStatus.meal_level > 200 &&
          characterStatus.sleep_level >= 200) {
        return '0amheadache';
      } else if (characterStatus.water_level > 200 &&
          characterStatus.meal_level <= 200 &&
          characterStatus.sleep_level >= 200) {
        return '0amstomach';
      } else if (characterStatus.water_level > 200 &&
          characterStatus.meal_level > 200 &&
          characterStatus.sleep_level < 200) {
        return '0amtired';
      }
    }
    return 'default';
  }

  String getTimeBasedOverride(String currentStatus, DateTime now) {
    final hour = now.hour;
    final isNight = (hour >= 22 || hour < 6);

    final overrideStatuses = [
      'default',
      'thirsty_and_hungry_dizzy',
      'thirsty_and_hungry',
      'thirsty_and_dizzy',
      'thirsty',
      'hungry',
      'dizzy',
    ];

    if (overrideStatuses.contains(currentStatus)) {
      return isNight ? '0am' : 'default';
    }

    return currentStatus;
  }
}
