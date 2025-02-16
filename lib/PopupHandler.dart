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

  
  
  final GlobalKey _imageKey = GlobalKey(); // 이미지를 위한 GlobalKey 선언
  Rect? _imageRect;

   void initialize() async{
    await loadStatusFromServer();
    setBodyPartStatus();
    
}


  final List<String> defaultImagePaths = [
    'assets/person/default/1.jpg',
    'assets/person/default/2.jpg',
    'assets/person/default/3.jpg',
    'assets/person/default/3.jpg',
    'assets/person/default/2.jpg',
    'assets/person/default/1.jpg',
  ];

  PopupHandler({required this.listData, required this.dioService, required this.tokenService})
      : imagePathsByBodyPart = {
          'head': [
            'assets/person/default/head1.jpg',
            'assets/person/default/head2.jpg',
            'assets/person/default/head3.jpg',
            'assets/person/default/head3.jpg',
            'assets/person/default/head2.jpg',
            'assets/person/default/head1.jpg',
          ],
          'body': [
            'assets/person/default/jindan_stomach1.jpg',
            'assets/person/default/jindan_stomach2.jpg',
            'assets/person/default/jindan_stomach3.jpg',
            'assets/person/default/jindan_stomach4.jpg',
            'assets/person/default/jindan_stomach5.jpg',
            'assets/person/default/jindan_stomach6.jpg',
            'assets/person/default/jindan_stomach7.jpg',
            'assets/person/default/jindan_stomach6.jpg',
            'assets/person/default/jindan_stomach5.jpg',
            'assets/person/default/jindan_stomach4.jpg',
            'assets/person/default/jindan_stomach3.jpg',
            'assets/person/default/jindan_stomach2.jpg',
            'assets/person/default/jindan_stomach1.jpg',
          ],
          'arm': [
            'assets/person/default/arm1.jpg',
            'assets/person/default/arm2.jpg',
            'assets/person/default/arm3.jpg',
            'assets/person/default/arm3.jpg',
            'assets/person/default/arm2.jpg',
            'assets/person/default/arm1.jpg',
          ],
          'leg': [
            'assets/person/default/leg1.jpg',
            'assets/person/default/leg2.jpg',
            'assets/person/default/leg3.jpg',
            'assets/person/default/leg4.jpg',
            'assets/person/default/leg3.jpg',
            'assets/person/default/leg2.jpg',
            'assets/person/default/leg1.jpg',
          ],
          'thirsty': [
            'assets/person/default/th1.jpg',
            'assets/person/default/th2.jpg',
            'assets/person/default/th3.jpg',
            'assets/person/default/th4.jpg',
            'assets/person/default/th4.jpg',
            'assets/person/default/th3.jpg',
            'assets/person/default/th2.jpg',
            'assets/person/default/th1.jpg',
          ],
          'thirsty_and_hungry': [
            'assets/person/default/headache1.jpg',
            'assets/person/default/headache2.jpg',
            'assets/person/default/headache3.jpg',
            'assets/person/default/headache3.jpg',
            'assets/person/default/headache2.jpg',
            'assets/person/default/headache1.jpg',
          ],
          'thirsty_and_hungry_dizzy':[
            'assets/person/default/dizzy1.jpg',
            'assets/person/default/dizzy2.jpg',
            'assets/person/default/dizzy3.jpg',
            'assets/person/default/dizzy3.jpg',
            'assets/person/default/dizzy2.jpg',
            'assets/person/default/dizzy1.jpg',
          ],
          'hungry_and_dizzy': [
            'assets/person/default/jindan_stomach1.jpg',
            'assets/person/default/jindan_stomach2.jpg',
            'assets/person/default/jindan_stomach3.jpg',
            'assets/person/default/jindan_stomach3.jpg',
            'assets/person/default/jindan_stomach2.jpg',
            'assets/person/default/jindan_stomach1.jpg',
          ],
          'dizzy':[
            'assets/person/default/tired1.jpg',
            'assets/person/default/tired2.jpg',
            'assets/person/default/tired3.jpg',
            'assets/person/default/tired3.jpg',
            'assets/person/default/tired2.jpg',
            'assets/person/default/tired1.jpg',
          ],
          'hungry': [
            'assets/person/default/hungry1.jpg',
            'assets/person/default/hungry2.jpg',
            'assets/person/default/hungry3.jpg',
            'assets/person/default/hungry3.jpg',
            'assets/person/default/hungry2.jpg',
            'assets/person/default/hungry1.jpg',
          ],
          'thirsty_and_dizzy': [
            'assets/person/default/jindan_sad1.jpg',
            'assets/person/default/jindan_sad2.jpg',
            'assets/person/default/jindan_sad3.jpg',
            'assets/person/default/jindan_sad3.jpg',
            'assets/person/default/jindan_sad2.jpg',
            'assets/person/default/jindan_sad1.jpg',
          ],
          'drinkwater': [
            'assets/person/default/drinkwater1.jpg',
            'assets/person/default/drinkwater2.jpg',
            'assets/person/default/drinkwater3.jpg',
            'assets/person/default/drinkwater3.jpg',
            'assets/person/default/drinkwater2.jpg',
            'assets/person/default/drinkwater1.jpg',
          ],
          'eatingmeal': [
            'assets/person/default/eatingmeal1.jpg',
            'assets/person/default/eatingmeal2.jpg',
            'assets/person/default/eatingmeal3.jpg',
            'assets/person/default/eatingmeal3.jpg',
            'assets/person/default/eatingmeal2.jpg',
            'assets/person/default/eatingmeal1.jpg',
          ],
          
          'yee': [
            'assets/person/default/yee1.jpg',
            'assets/person/default/yee2.jpg',
            'assets/person/default/yee3.jpg',
            'assets/person/default/yee3.jpg',
            'assets/person/default/yee2.jpg',
            'assets/person/default/yee1.jpg',
          ],
          'brush': [
            'assets/person/default/brush.jpg',
            'assets/person/default/brush1.jpg',
            'assets/person/default/brush.jpg',
            'assets/person/default/brush1.jpg',
            'assets/person/default/brush.jpg',
            'assets/person/default/brush1.jpg',
            'assets/person/default/brush.jpg',
            'assets/person/default/brush1.jpg',
            'assets/person/default/brush.jpg',
            'assets/person/default/brush1.jpg',
          ],
          'nobrush': [
            'assets/person/default/nobrush1.jpg',
            'assets/person/default/nobrush2.jpg',
            'assets/person/default/nobrush3.jpg',
            'assets/person/default/nobrush3.jpg',
            'assets/person/default/nobrush2.jpg',
            'assets/person/default/nobrush1.jpg',
          ],
          'angry': [
            'assets/person/default/angry1.jpg',
            'assets/person/default/angry2.jpg',
            'assets/person/default/angry3.jpg',
            'assets/person/default/angry4.jpg',
            'assets/person/default/angry5.jpg',
            'assets/person/default/angry6.jpg',
            'assets/person/default/angry6.jpg',
            'assets/person/default/angry5.jpg',
            'assets/person/default/angry4.jpg',
            'assets/person/default/angry3.jpg',
            'assets/person/default/angry2.jpg',
            'assets/person/default/angry1.jpg',
          ],
          'smile': [
            'assets/person/default/smile1.jpg',
            'assets/person/default/smile2.jpg',
            'assets/person/default/smile3.jpg',
            'assets/person/default/smile3.jpg',
            'assets/person/default/smile2.jpg',
            'assets/person/default/smile1.jpg',
          ],
          'medication': [
            'assets/person/default/medi1.jpg',
            'assets/person/default/medi2.jpg',
            'assets/person/default/medi3.jpg',
            'assets/person/default/medi3.jpg',
            'assets/person/default/medi2.jpg',
            'assets/person/default/medi1.jpg',
          ],
          'waist': [
            'assets/person/default/waist1.jpg',
            'assets/person/default/waist2.jpg',
            'assets/person/default/waist3.jpg',
            'assets/person/default/waist3.jpg',
            'assets/person/default/waist2.jpg',
            'assets/person/default/waist1.jpg',
          ],//여기부터 0am
          'sleeping': [
            'assets/person/0am/sleeping1.jpg',
            'assets/person/0am/sleeping2.jpg',
            'assets/person/0am/sleeping3.jpg',
            'assets/person/0am/sleeping4.jpg',
            'assets/person/0am/sleeping5.jpg',
            'assets/person/0am/sleeping6.jpg',
            'assets/person/0am/sleeping6.jpg',
            'assets/person/0am/sleeping5.jpg',
            'assets/person/0am/sleeping4.jpg',
            'assets/person/0am/sleeping3.jpg',
            'assets/person/0am/sleeping2.jpg',
            'assets/person/0am/sleeping1.jpg',
          ],
          '0am': [
            'assets/person/0am/0am.jpg',
            'assets/person/0am/0am1.jpg',
            'assets/person/0am/0am2.jpg',
            'assets/person/0am/0am2.jpg',
            'assets/person/0am/0am1.jpg',
            'assets/person/0am/0am.jpg',
          ],
          '0amtouch': [
            'assets/person/0am/0amtouch1.jpg',
            'assets/person/0am/0amtouch2.jpg',
            'assets/person/0am/0amtouch3.jpg',
            'assets/person/0am/0amtouch3.jpg',
            'assets/person/0am/0amtouch2.jpg',
            'assets/person/0am/0amtouch1.jpg',
          ],
          '0amarm': [
            'assets/person/0am/0amarm1.jpg',
            'assets/person/0am/0amarm2.jpg',
            'assets/person/0am/0amarm3.jpg',
            'assets/person/0am/0amarm3.jpg',
            'assets/person/0am/0amarm2.jpg',
            'assets/person/0am/0amarm1.jpg',

          ],
          '0amhead': [
            'assets/person/slhead1.jpg',
            'assets/person/slhead2.jpg',
            'assets/person/slhead3.jpg',
            'assets/person/slhead3.jpg',
            'assets/person/slhead2.jpg',
            'assets/person/slhead1.jpg',
          ],
          '0amnobrush': [
            'assets/person/0am/0amnobrush1.jpg',
            'assets/person/0am/0amnobrush2.jpg',
            'assets/person/0am/0amnobrush3.jpg',
            'assets/person/0am/0amnobrush3.jpg',
            'assets/person/0am/0amnobrush2.jpg',
            'assets/person/0am/0amnobrush1.jpg',
          ],
          
          '0amsupplement':[
            'assets/person/0am/0amsu1.jpg',
            'assets/person/0am/0amsu2.jpg',
            'assets/person/0am/0amsu3.jpg',
            'assets/person/0am/0amsu3.jpg',
            'assets/person/0am/0amsu2.jpg',
            'assets/person/0am/0amsu1.jpg',
          ],
          '0amstomach':[
            'assets/person/0am/0amstomach1.jpg',
            'assets/person/0am/0amstomach2.jpg',
            'assets/person/0am/0amstomach3.jpg',
            'assets/person/0am/0amstomach3.jpg',
            'assets/person/0am/0amstomach2.jpg',
            'assets/person/0am/0amstomach1.jpg',
          ],
          '0ambrush':[
            'assets/person/0am/0ambrush1',
            'assets/person/0am/0ambrush2',
            'assets/person/0am/0ambrush1',
            'assets/person/0am/0ambrush2',
            'assets/person/0am/0ambrush1',
            'assets/person/0am/0ambrush2',
            'assets/person/0am/0ambrush1',
            'assets/person/0am/0ambrush2',
          ]

        } {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
    loadStatusFromServer();
  }
  void updateStatus({required int newWaterLevel, required int newMealLevel, required int newSleepLevel}) async {
    print("Updating status - Water: $newWaterLevel, Meal: $newMealLevel, Sleep: $newSleepLevel");

  
   
      waterLevel = newWaterLevel;
      mealLevel = newMealLevel;
      sleepLevel = newSleepLevel;

      // 상태 업데이트 후 서버에 저장
      await saveStatusToServer();
      

      
      setBodyPartStatus(); // 새로운 상태에 따라 이미지 경로 설정
      startImageAnimation(); // 애니메이션 다시 시작
      
      print("Status updated and animation started - Current Body Part: $_currentBodyPart");
}
   /// 서버에 현재 상태 저장
Future<void> saveStatusToServer() async {
  try {
    String? username = await TokenService().getUsername();
    String? jwtToken = await TokenService().getToken(); // 토큰 가져오기

    // username이 이메일이면 변환
    if (username != null && username.contains("@")) {
      username = await fetchUsernameFromServer(username);
    }

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

Future<String> fetchUsernameFromServer(String email) async {
  try {
    final response = await DioService().getDio().get(
      '/getUsernameByEmail',
      queryParameters: {'email': email},
    );
    return response.data['username'];
  } catch (e) {
    print("❌ Error fetching username: $e");
    return email; // 오류 시 기존 이메일 유지
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
      startImageAnimation(); // 상태 업데이트 후 애니메이션 재시작
      print('Status loaded from server successfully');
    }
  } catch (e) {
    print('Failed to load status from server: $e');
  }
}
 


  void setBodyPartStatus() {
     String PreviousBodyPart =_currentBodyPart;
    // 세 가지 상태의 조합에 따른 상태 설정
    if (waterLevel <= 200 && mealLevel <= 200 && sleepLevel <= 200) {
      _currentBodyPart = 'thirsty_and_hungry_dizzy';
    } else if (waterLevel <= 200 && mealLevel <= 200 && sleepLevel >= 200) {
      _currentBodyPart = 'thirsty_and_hungry';
    } else if (waterLevel <= 200 && mealLevel > 200 && sleepLevel < 200) {
      _currentBodyPart = 'thirsty_and_dizzy';
    } else if (waterLevel > 200 && mealLevel <= 200 && sleepLevel < 200) {
      _currentBodyPart = 'hungry_and_dizzy';
    } else if (waterLevel <= 200 && mealLevel > 200 && sleepLevel >= 200) {
      _currentBodyPart = 'thirsty';
    } else if (waterLevel > 200 && mealLevel <= 200 && sleepLevel >= 200) {
      _currentBodyPart = 'hungry';
    } else if (waterLevel > 200 && mealLevel > 200 && sleepLevel < 200) {
      _currentBodyPart = 'dizzy';
    } else {
      updateCharacterStatusBasedOnTime();
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
void triggerAnimation(String bodyPart, {int delayMilliseconds = 1000}) {
  print("Triggering animation for: $bodyPart");

  // 해당 bodyPart에 대한 이미지가 있는지 확인
  if (imagePathsByBodyPart[bodyPart]?.isEmpty ?? true) {
    print("No images available for body part: $bodyPart");
    return;
  }

  // 기존 타이머 중지
  _imageTimer?.cancel();
  _imageNotifier.value = 0; // 애니메이션 초기화
  String previousBodyPart = _currentBodyPart; // 이전 상태 저장
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

      // 일정 시간 후 원래 상태 복구
      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        // 상태 복구
        _currentBodyPart = previousBodyPart; // 이전 상태로 복구
        setBodyPartStatus(); // 상태 업데이트
        startImageAnimation(); // 복구된 상태로 애니메이션 재시작
        print("Character state restored to $_currentBodyPart");
      });
    }
  });
}


  void updateCharacterStatusBasedOnTime() {
    DateTime now = DateTime.now(); // 현재 시간 가져오기
    int hour = now.hour;

    

   
    // 10시 이후 상태 변경
      if (hour >= 22 || hour < 6) {
        if( _currentBodyPart == 'thirsty_and_hungry_dizzy'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart=='thirsty_and_hungry'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart == 'thirsty_and_dizzy'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart == 'hungry_and_dizzy'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart =='thirsty'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart=='hungry'){
          _currentBodyPart='0amstomach';
        }else if(_currentBodyPart =='dizzy'){
          _currentBodyPart='0amstomach';
        }else {
        _currentBodyPart = '0am'; // 잠옷바람 상태
        }
      } 
   

    
    print("Character status updated based on time: $_currentBodyPart");
  }

  void startPeriodicStatusUpdate() {
    _imageTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateCharacterStatusBasedOnTime();
    });
  }

  void stopPeriodicStatusUpdate() {
    _imageTimer?.cancel();
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
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, 배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를 잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'thirsty_and_dizzy') {
        popupMessage = '충분한 숙면을 취하지 못했어요, 목도 말라요.';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, 배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를 잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'thirsty_and_hungry_dizzy') {
        popupMessage = '건강을 챙겨주세요';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, 배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를 잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'thirsty_and_hungry') {
        popupMessage = '목도 마르고 배도 고파요... 물과 식사가 필요해요!';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, 배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를 잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'hungry_and_dizzy') {
        popupMessage = '충분한 숙면과 밥을 챙겨주세요';
      } else if (_currentBodyPart == '0am'){
        popupMessage = '좋은 꿈꾸세요!';
          if (relativeY < headHeight) {
          popupMessage = '주무실 시간이네요!';
          triggerAnimation('0amhead');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '오늘의 파자마는 보라색이예요.';
            triggerAnimation('0amarm');
          } else {
            popupMessage = '오늘은 어떤 하루였나요?';
            triggerAnimation('0amtouch');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '오늘 하루도 수고 많으셨어요.';
          triggerAnimation('0amtouch');
        } 
      }else if (_currentBodyPart == '0amstomach'){
        popupMessage = '몸을 조금 더 챙겨주세요.';
          if (relativeY < headHeight) {
          popupMessage = '아파요';
          triggerAnimation('0amstomach');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '피곤해요';
            triggerAnimation('0amstomach');
          } else {
            popupMessage = '피곤해요';
            triggerAnimation('0amstomach');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '아파요';
          triggerAnimation('0amtouch');
        } 
      }else if (_currentBodyPart == 'dizzy') {
        popupMessage = '수면 시간을 늘려주세요!';
      }
      else {
      // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '잘 주무셨나요?';
          _currentBodyPart = 'head';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '오늘 하루도 화이팅!';
            _currentBodyPart = 'arm';
          } else {
            popupMessage = '식사 하셨나요?';
            _currentBodyPart = 'waist';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '다리가 아프신가요?';
          _currentBodyPart = 'smile';
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

              ],
            ),
          ),
        ],
      );
    }
  }

  Widget buildImageAnimationWithTouch(BuildContext context, Function(String) onImageSelected) {
  startImageAnimation(); // 애니메이션 시작

  return LayoutBuilder(
    builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (TapDownDetails details) {
          _calculateImageRect();
          final tapPosition = details.globalPosition;
          
          showPopupForCoordinates(context, tapPosition, onImageSelected);
          
           setBodyPartStatus();
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
    stopPeriodicStatusUpdate();
  }
}