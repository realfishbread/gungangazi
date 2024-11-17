import 'MealPage.dart';
import 'SleepPage.dart';
import 'SupplementsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/dio_service.dart'; // DioService 추가
import '../services/TokenService.dart';
import 'package:dio/dio.dart';

class PopupHandler {
  final List<dynamic> listData;
  final DioService dioService; // DioService 인스턴스
  final TokenService tokenService; // TokenService 인스턴스
  final Map<String, List<String>> imagePathsByBodyPart;
  int _currentImageIndex = 0;
  late ValueNotifier<int> _imageNotifier;
  Timer? _imageTimer;
  Duration frameDuration = const Duration(milliseconds: 300);
  String _currentBodyPart = 'default';
  int waterLevel = 100; // 수분 상태 변수 추가
  int mealLevel = 100;
  int sleepLevel = 100; // 수면 상태 변수

  
  

  final int waterLevelThreshold = 100; 
  final int mealLevelThreshold = 100; // 식사 기준 값
  final int sleepLevelThreshold = 100;
  final GlobalKey _imageKey = GlobalKey(); // 이미지를 위한 GlobalKey 선언
  Rect? _imageRect;

  // 기본 이미지 리스트 (애니메이션을 위해 여러 장)
  final List<String> defaultImagePaths = [
    'assets/person/1.jpg',
    'assets/person/2.jpg',
    'assets/person/3.jpg',
    'assets/person/4.jpg',
    'assets/person/5.jpg',
    'assets/person/6.jpg',
    'assets/person/7.jpg',
    'assets/person/8.jpg',
    'assets/person/9.jpg',
    'assets/person/10.jpg',
    'assets/person/11.jpg',
    'assets/person/12.jpg',
    'assets/person/12.jpg',
    'assets/person/11.jpg',
    'assets/person/10.jpg',
    'assets/person/9.jpg',
    'assets/person/8.jpg',
    'assets/person/7.jpg',
    'assets/person/6.jpg',
    'assets/person/5.jpg',
    'assets/person/4.jpg',
    'assets/person/3.jpg',
    'assets/person/2.jpg',
    'assets/person/1.jpg',
  ];

  PopupHandler({required this.listData, required this.dioService, required this.tokenService})
      : imagePathsByBodyPart = {
          'head': [
            'assets/person/jindan_sad1.jpg',
            'assets/person/jindan_sad2.jpg',
            'assets/person/jindan_sad3.jpg',
            'assets/person/jindan_sad4.jpg',
            'assets/person/jindan_sad5.jpg',
            'assets/person/jindan_sad6.jpg',
            'assets/person/jindan_sad7.jpg',
            'assets/person/jindan_sad8.jpg',
            'assets/person/jindan_sad9.jpg',
          ],
          'body': [
            'assets/person/jindan_stomach1.jpg',
            'assets/person/jindan_stomach2.jpg',
            'assets/person/jindan_stomach3.jpg',
            'assets/person/jindan_stomach4.jpg',
            'assets/person/jindan_stomach5.jpg',
            'assets/person/jindan_stomach6.jpg',
            'assets/person/jindan_stomach7.jpg',
            'assets/person/jindan_stomach6.jpg',
            'assets/person/jindan_stomach5.jpg',
            'assets/person/jindan_stomach4.jpg',
            'assets/person/jindan_stomach3.jpg',
            'assets/person/jindan_stomach2.jpg',
            'assets/person/jindan_stomach1.jpg',
          ],
          'arm': [
            'assets/person/jindan_armsick1.jpg',
            'assets/person/jindan_armsick3.jpg',
            'assets/person/jindan_armsick5.jpg',
            'assets/person/jindan_armsick7.jpg',
            'assets/person/jindan_armsick9.jpg',
            'assets/person/jindan_armsick11.jpg',
            'assets/person/jindan_armsick13.jpg',
            'assets/person/jindan_armsick16.jpg',
            'assets/person/jindan_armsick13.jpg',
            'assets/person/jindan_armsick11.jpg',
            'assets/person/jindan_armsick9.jpg',
            'assets/person/jindan_armsick7.jpg',
            'assets/person/jindan_armsick5.jpg',
            'assets/person/jindan_armsick3.jpg',
            'assets/person/jindan_armsick1.jpg',
          ],
          'leg': [
            'assets/person/leg1.jpg',
            'assets/person/leg2.jpg',
            'assets/person/leg3.jpg',
            'assets/person/leg4.jpg',
            'assets/person/leg3.jpg',
            'assets/person/leg2.jpg',
            'assets/person/leg1.jpg',
          ],
          'thirsty': [
            'assets/person/th1.jpg',
            'assets/person/th2.jpg',
            'assets/person/th3.jpg',
            'assets/person/th4.jpg',
            'assets/person/th4.jpg',
            'assets/person/th3.jpg',
            'assets/person/th2.jpg',
            'assets/person/th1.jpg',
          ],
          'thirsty_and_hungry': [
            'assets/person/headache1.jpg',
            'assets/person/headache2.jpg',
            'assets/person/headache3.jpg',
            'assets/person/headache4.jpg',
            'assets/person/headache5.jpg',
            'assets/person/headache6.jpg',
            'assets/person/headache7.jpg',
            'assets/person/headache6.jpg',
            'assets/person/headache5.jpg',
            'assets/person/headache4.jpg',
            'assets/person/headache3.jpg',
            'assets/person/headache2.jpg',
            'assets/person/headache1.jpg',
          ],
          'thirsty_and_hungry_dizzy':[
            'assets/person/dizzy1.jpg',
            'assets/person/dizzy2.jpg',
            'assets/person/dizzy3.jpg',
            'assets/person/dizzy4.jpg',
            'assets/person/dizzy3.jpg',
            'assets/person/dizzy2.jpg',
            'assets/person/dizzy1.jpg',
          ],
          'hungry_and_dizzy': [
            'assets/person/jindan_stomach1.jpg',
            'assets/person/jindan_stomach2.jpg',
            'assets/person/jindan_stomach3.jpg',
            'assets/person/jindan_stomach4.jpg',
            'assets/person/jindan_stomach5.jpg',
            'assets/person/jindan_stomach6.jpg',
            'assets/person/jindan_stomach7.jpg',
            'assets/person/jindan_stomach6.jpg',
            'assets/person/jindan_stomach5.jpg',
            'assets/person/jindan_stomach4.jpg',
            'assets/person/jindan_stomach3.jpg',
            'assets/person/jindan_stomach2.jpg',
            'assets/person/jindan_stomach1.jpg',
          ],
          'dizzy':[
            'assets/person/tired1.jpg',
            'assets/person/tired2.jpg',
            'assets/person/tired3.jpg',
          ],
          'hungry': [
            'assets/person/yee.jpg',
          ],
          'thirsty_and_dizzy': [
            'assets/person/yeet,jpg'
          ],
          'drinkwater': [
            'assets/person/drinkwater1.jpg',
            'assets/person/drinkwater2.jpg',
            'assets/person/drinkwater3.jpg',
            'assets/person/drinkwater3.jpg',
            'assets/person/drinkwater2.jpg',
            'assets/person/drinkwater1.jpg',
          ],
          'eatingmeal': [
            'assets/person/eatingmeal1.jpg',
            'assets/person/eatingmeal2.jpg',
            'assets/person/eatingmeal3.jpg',
            'assets/person/eatingmeal3.jpg',
            'assets/person/eatingmeal2.jpg',
            'assets/person/eatingmeal1.jpg',
          ],
          'sleeping': [
            'assets/person/sleeping1.jpg',
            'assets/person/sleeping2.jpg',
            'assets/person/sleeping3.jpg',
            'assets/person/sleeping4.jpg',
            'assets/person/sleeping5.jpg',
            'assets/person/sleeping6.jpg',
            'assets/person/sleeping6.jpg',
            'assets/person/sleeping5.jpg',
            'assets/person/sleeping4.jpg',
            'assets/person/sleeping3.jpg',
            'assets/person/sleeping2.jpg',
            'assets/person/sleeping1.jpg',
          ],
          '0am': [
            'assets/person/0am.jpg',
            'assets/person/0am1.jpg',
            'assets/person/0am2.jpg',
          ]

        } {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
    loadStatusFromServer();
  }
  void updateStatus({required int newWaterLevel, required int newMealLevel, required int newSleepLevel}) async {
    print("Updating status - Water: $newWaterLevel, Meal: $newMealLevel, Sleep: $newSleepLevel");

    // 수치 변화 여부 확인
    bool isWaterChanged = waterLevel != newWaterLevel;
    bool isMealChanged = mealLevel != newMealLevel;
    bool isSleepChanged = sleepLevel != newSleepLevel;

    // 현재 상태 업데이트
    waterLevel = newWaterLevel;
    mealLevel = newMealLevel;
    sleepLevel = newSleepLevel;

    // 상태 업데이트 후 서버에 저장
    await saveStatusToServer();

    // 상태가 변한 경우에만 애니메이션 실행
    if (isWaterChanged || isMealChanged || isSleepChanged) {
      print("Status changed, triggering animation...");
      setBodyPartStatus(); // 새로운 상태에 따라 이미지 경로 설정
      startImageAnimation(); // 애니메이션 다시 시작
      print("Animation started - Current Body Part: $_currentBodyPart");
    } else {
      print("No status changes, animation not triggered.");
    }
}
   /// 서버에 현재 상태 저장
Future<void> saveStatusToServer() async {
  try {
    String? username = await TokenService().getUsername();
    String? jwtToken = await TokenService().getToken(); // 토큰 가져오기

    print('Saving status - Username: $username, Water Level: $waterLevel, Meal Level: $mealLevel, Sleep Level: $sleepLevel'); // 확인용 로그

    await DioService().getDio().post(
      '/character/status',
      data: {
        'username': username,
        'water_level': waterLevel,
        'meal_level': mealLevel,
        'sleep_level': sleepLevel,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $jwtToken', // JWT 토큰 헤더 추가
        },
      ),
    );

    print('Status saved to server successfully');
  } catch (e) {
    print('Failed to save status to server: $e');
  }
}

/// 서버에서 현재 상태 불러오기
Future<void> loadStatusFromServer() async {
  try {
    String? username = await TokenService().getUsername();
    String? jwtToken = await TokenService().getToken(); // 토큰 가져오기

    final response = await DioService().getDio().get(
      '/character/status',
      queryParameters: {
        'username': username,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $jwtToken', // JWT 토큰 헤더 추가
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      waterLevel = data['water_level'] ?? 100;
      mealLevel = data['meal_level'] ?? 100;
      sleepLevel = data['sleep_level'] ?? 100;
      setBodyPartStatus();
      print('Status loaded from server successfully');
    }
  } catch (e) {
    print('Failed to load status from server: $e');
  }
}
 

  void setBodyPartStatus() {
    // 세 가지 상태의 조합에 따른 상태 설정
    if (waterLevel <= 200 && mealLevel <= 200 && sleepLevel <= 200) {
      _currentBodyPart = 'thirsty_and_hungry_dizzy';
    } else if (waterLevel <= 200 && mealLevel <= 200 && sleepLevel > 200) {
      _currentBodyPart = 'thirsty_and_hungry';
    } else if (waterLevel <= 200 && mealLevel > 200 && sleepLevel <= 200) {
      _currentBodyPart = 'thirsty_and_dizzy';
    } else if (waterLevel > 200 && mealLevel <= 200 && sleepLevel <= 200) {
      _currentBodyPart = 'hungry_and_dizzy';
    } else if (waterLevel <= 200 && mealLevel > 200 && sleepLevel > 200) {
      _currentBodyPart = 'thirsty';
    } else if (waterLevel > 200 && mealLevel <= 200 && sleepLevel > 200) {
      _currentBodyPart = 'hungry';
    } else if (waterLevel > 200 && mealLevel > 200 && sleepLevel <= 200) {
      _currentBodyPart = 'dizzy';
    } else {
      _currentBodyPart = 'default';
    }
    print("Body part status set to $_currentBodyPart based on Water: $waterLevel, Meal: $mealLevel, Sleep: $sleepLevel");
  }

  // 이미지 애니메이션 시작
  void startImageAnimation() {
    _imageTimer?.cancel(); // 기존 타이머 중지

    _imageTimer = Timer.periodic(frameDuration, (timer) {
      _currentImageIndex = (_currentImageIndex + 1) %
          (imagePathsByBodyPart[_currentBodyPart]?.length ?? defaultImagePaths.length);
      _imageNotifier.value = _currentImageIndex;
    });
  }

  // 이미지 애니메이션 중지
  void stopImageAnimation() {
    _imageTimer?.cancel();
  }

  // 이미지의 위치 및 크기를 계산하는 함수
  void _calculateImageRect() {
    final RenderBox? box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      Size size = box.size;
      _imageRect = position & size;
    }
  }

   /// 특정 상태에 맞는 애니메이션 실행
void triggerAnimation(String bodyPart, {int delayMilliseconds = 2000}) {
  print("Triggering animation for: $bodyPart");

  // 해당 bodyPart에 대한 이미지가 있는지 확인
  if (imagePathsByBodyPart[bodyPart]?.isEmpty ?? true) {
    print("No images available for body part: $bodyPart");
    return;
  }

  // 기존 타이머를 중지하고 초기화
  _imageTimer?.cancel();
  _imageNotifier.value = 0; // 애니메이션 초기화
  _currentBodyPart = bodyPart; // 현재 애니메이션 상태 설정

  // 애니메이션 실행을 위한 타이머 시작
  _imageTimer = Timer.periodic(frameDuration, (timer) {
    // 이미지 인덱스를 업데이트
    _currentImageIndex = (_currentImageIndex + 1) % imagePathsByBodyPart[bodyPart]!.length;
    _imageNotifier.value = _currentImageIndex;

    // 마지막 이미지에 도달했을 때 타이머 중지
    if (_currentImageIndex == imagePathsByBodyPart[bodyPart]!.length - 1) {
      print("Animation for $bodyPart completed");
      timer.cancel();

      // 일정 시간 후 기본 상태로 복구
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        setBodyPartStatus();
        _imageNotifier.value = 0;
        print("Character state restored to $_currentBodyPart");
      });
    }
  });
}


 

  // 터치 이벤트 및 팝업
  void showPopupForCoordinates(
      BuildContext context, Offset tapPosition, Function(String) onImageSelected) {
    if (_imageRect == null) return;

    String popupMessage = '';

    // 터치 위치가 이미지 범위 내에 있는지 확인
    if (_imageRect!.contains(tapPosition)) {
      double relativeY = tapPosition.dy - _imageRect!.top;
      double relativeX = tapPosition.dx - _imageRect!.left;

      double imageHeight = _imageRect!.height;
      double imageWidth = _imageRect!.width;

      double headHeight = imageHeight * 0.40;
      double bodyHeight = imageHeight * 0.30;
      double legStartHeight = imageHeight * 0.55;
      double legEndHeight = imageHeight * 0.90;
      double armWidth = imageWidth * 0.3;

      // 물 부족 상태일 때 팝업 메시지 설정
    if (_currentBodyPart == 'thirsty') {
      popupMessage = '목이 말라요... 물을 주세요!';
    } else if (_currentBodyPart == 'hungry') {
        popupMessage = '배고파요... 식사를 해주세요!!';
      } else if (_currentBodyPart == 'thirsty_and_dizzy') {
        popupMessage = '충분한 숙면을 취하지 못했어요, 목도 말라요.';
      } else if (_currentBodyPart == 'thirsty_and_hungry_dizzy') {
        popupMessage = '건강을 챙겨주세요';
      } else if (_currentBodyPart == 'thirsty_and_hungry') {
        popupMessage = '목도 마르고 배도 고파요... 물과 식사가 필요해요!';
      } else if (_currentBodyPart == 'hungry_and_dizzy') {
        popupMessage = '충분한 숙면과 밥을 챙겨주세요';
      } else {
      // 부위별 팝업 메시지 설정
      if (relativeY < headHeight) {
        popupMessage = '잘 주무셨나요?';
        _currentBodyPart = 'head';
      } else if (relativeY >= headHeight && relativeY < legStartHeight) {
        if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
          popupMessage = '팔이 아프신가요?';
          _currentBodyPart = 'arm';
        } else {
          popupMessage = '식사 하셨나요?';
          _currentBodyPart = 'body';
        }
      } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
        popupMessage = '다리가 아프신가요?';
        _currentBodyPart = 'leg';
      }
    }

      // 말풍선 형태의 팝업 표시
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(tapPosition.dx, tapPosition.dy, tapPosition.dx, tapPosition.dy),
        items: [
          PopupMenuItem(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(popupMessage),
                const SizedBox(height: 10),
                listData.isNotEmpty
                    ? SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: listData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(listData[index]['title'].toString()),
                        onTap: () {
                          onImageSelected(listData[index]['imagePath']);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                )
                    : const SizedBox(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('다른 페이지로 이동'),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  // 터치 이벤트와 이미지 애니메이션 처리
  Widget buildImageAnimationWithTouch(BuildContext context, Function(String) onImageSelected) {
    startImageAnimation(); // 애니메이션 시작

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (TapDownDetails details) {
            _calculateImageRect();
            final tapPosition = details.globalPosition;
            showPopupForCoordinates(context, tapPosition, onImageSelected);
          },
          child: ValueListenableBuilder<int>(
            valueListenable: _imageNotifier,
            builder: (context, value, child) {
              return Image.asset(
                _currentBodyPart == 'default'
                    ? defaultImagePaths[value]
                    : imagePathsByBodyPart[_currentBodyPart]![value],
                fit: BoxFit.cover,
                key: _imageKey,
                gaplessPlayback: true,
              );
            },
          ),
        );
      },
    );
  }

  // 리소스 해제
  void dispose() {
    stopImageAnimation();
  }
}