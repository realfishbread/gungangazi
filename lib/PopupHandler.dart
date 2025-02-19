import 'MealPage.dart';
import 'SleepPage.dart';
import 'SupplementsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../core_services/dio_service.dart'; // DioService 추가
import '../core_services/token_service.dart';
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
            'assets/person/0am/slhead1.jpg',
            'assets/person/0am/slhead2.jpg',
            'assets/person/0am/slhead3.jpg',
            'assets/person/0am/slhead3.jpg',
            'assets/person/0am/slhead2.jpg',
            'assets/person/0am/slhead1.jpg',
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
          ],
          '0amheadache':[
            'assets/person/0am/0amheadache1',
            'assets/person/0am/0amheadache2',
            'assets/person/0am/0amheadache3',
            'assets/person/0am/0amheadache3',
            'assets/person/0am/0amheadache2',
            'assets/person/0am/0amheadache1',
          ],
          '0amtired': [
            'assets/person/0am/0amtired1',
            'assets/person/0am/0amtired2',
            'assets/person/0am/0amtired3',
            'assets/person/0am/0amtired3',
            'assets/person/0am/0amtired2',
            'assets/person/0am/0amtired1',

          ],
          '0amdizzy': [
            'assets/person/0am/0amdizzy1',
            'assets/person/0am/0amdizzy2',
            'assets/person/0am/0amdizzy3',
            'assets/person/0am/0amdizzy3',
            'assets/person/0am/0amdizzy2',
            'assets/person/0am/0amdizzy1',
          ]

        }{
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
  String previousBodyPart = _currentBodyPart;

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
    updateCharacterStatusBasedOnTime(); // ⏰ 시간 기반 상태 업데이트
  }

  // 🔥 상태가 바뀔 때만 애니메이션 다시 시작!
  if (previousBodyPart != _currentBodyPart) {
    print("📢 캐릭터 상태 변경됨: $_currentBodyPart → 애니메이션 재시작!");
    startImageAnimation();
  }
}

  // 이미지 애니메이션 시작
  void startImageAnimation() {
  _imageTimer?.cancel(); // 기존 타이머 중지

  _imageTimer = Timer.periodic(frameDuration, (timer) {
    _currentImageIndex = (_currentImageIndex + 1) %
        (imagePathsByBodyPart[_currentBodyPart]?.length ?? defaultImagePaths.length);

    _imageNotifier.value = _currentImageIndex; // ✅ 애니메이션 적용
    print("🎞 Updating image index: $_currentImageIndex for $_currentBodyPart"); // 🔥 로그 확인
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
bool _isAnimating = false; // ✅ 애니메이션 진행 여부 변수 추가

void triggerAnimation(String bodyPart, {int delayMilliseconds = 1000}) {
  if (_isAnimating) {
    print("🚫 Animation already in progress, ignoring new request for: $bodyPart");
    return; // ✅ 이미 애니메이션이 실행 중이면 중복 실행 방지
  }
  
  print("Triggering animation for: $bodyPart");
  _isAnimating = true; // ✅ 애니메이션 시작 표시

  // 기존 애니메이션 취소
  _imageTimer?.cancel();
  _imageNotifier.value = 0;
  String previousBodyPart = _currentBodyPart;
  _currentBodyPart = bodyPart;

  _imageTimer = Timer.periodic(frameDuration, (timer) {
    _currentImageIndex = (_currentImageIndex + 1) % imagePathsByBodyPart[bodyPart]!.length;
    _imageNotifier.value = _currentImageIndex;

    if (_currentImageIndex == imagePathsByBodyPart[bodyPart]!.length - 1) {
      print("✅ Animation for $bodyPart completed");
      timer.cancel();

      Future.delayed(Duration(milliseconds: delayMilliseconds), () {
        _currentBodyPart = previousBodyPart;
        setBodyPartStatus();
        startImageAnimation();
        _isAnimating = false; // ✅ 애니메이션 완료 후 다시 실행 가능하도록 설정
        print("🎭 Character state restored to $_currentBodyPart");
      });
    }
  });
}




   void updateCharacterStatusBasedOnTime() {
    DateTime now = DateTime.now(); // 현재 시간 가져오기
    int hour = now.hour;

    

   if (_currentBodyPart== 'default'){
    // 10시 이후 상태 변경
      if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }
   }else if(_currentBodyPart == 'thirsty_and_hungry_dizzy'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }

   }else if(_currentBodyPart=='thirsty_and_hungry'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }

   }else if(_currentBodyPart =='thirsty_and_dizzy'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }

   }else if(_currentBodyPart=='thirsty'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }

   }else if(_currentBodyPart=='hungry'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
      }

   }else if(_currentBodyPart=='dizzy'){
    if (hour >= 22 || hour < 6) {
        _currentBodyPart = '0am'; // 잠옷바람 상태
      } else {
        _currentBodyPart = 'default'; // 기본 상태
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
      popupMessage = '목이 말라요... \n물을 주세요!';
    } else if (_currentBodyPart == 'hungry') {
        popupMessage = '배고파요... \n식사를 해주세요!!';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고,\n배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를\n잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'thirsty_and_dizzy') {
        popupMessage = '충분한 숙면을 \n취하지 못했어요,\n목도 말라요.';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고,\n배가 고파요';
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
            popupMessage = '목을 축이고 싶고, \n배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분 섭취를\n잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'thirsty_and_hungry') {
        popupMessage = '목도 마르고 \n배도 고파요,\n 물과 식사가 필요해요!';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
          _currentBodyPart = 'angry';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, \n배가 고파요';
            _currentBodyPart = 'angry';
          } else {
            popupMessage = '수분섭취를\n잊지 말아주세요';
            _currentBodyPart = 'angry';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
          _currentBodyPart = 'angry';
        }
      } else if (_currentBodyPart == 'hungry_and_dizzy') {
        popupMessage = '충분한 숙면과\n밥을 챙겨주세요';
      } else if (_currentBodyPart == '0am'){
        popupMessage = '좋은 꿈꾸세요!';
          if (relativeY < headHeight) {
          popupMessage = '주무실 시간이네요!';
          triggerAnimation('0amhead');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '오늘의 파자마는\n 보라색이예요.';
            triggerAnimation('0amarm');
          } else {
            popupMessage = '오늘은 \n어떤 하루였나요?';
            triggerAnimation('0amtouch');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '오늘 하루도 \n수고 많으셨어요.';
          triggerAnimation('0amtouch');
        } 
      }else if (_currentBodyPart == '0amstomach'){
        popupMessage = '몸을 조금 \n더 챙겨주세요.';
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
     showDialog(
  context: context,
  barrierColor: Colors.transparent, // ✅ 배경 완전 투명화
  builder: (BuildContext context) {
    // 현재 화면 크기 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 팝업 위치 조정 (말풍선이 화면을 벗어나지 않도록)
    double adjustedLeft = tapPosition.dx;
    double adjustedTop = tapPosition.dy;

    // 가로 위치 조정 (말풍선이 우측 화면을 벗어나지 않도록)
    if (adjustedLeft + 220 > screenWidth) {
      adjustedLeft = screenWidth - 230;
    }
    if (adjustedLeft < 10) {
      adjustedLeft = 10;
    }

    // 세로 위치 조정 (말풍선이 하단 화면을 벗어나지 않도록)
    if (adjustedTop + 150 > screenHeight) {
      adjustedTop = screenHeight - 180;
    }
    if (adjustedTop < 10) {
      adjustedTop = 10;
    }

    return StatefulBuilder(
  builder: (context, setState) {
    double opacityLevel = 1.0; // ✅ 초기 투명도 (완전히 보이게)

    void fadeOutAndClose() {
      print("🔄 Fade-out animation 시작");
      
      setState(() {
        opacityLevel = 0.0; // ✅ 서서히 투명하게 만들기
      });

      // onEnd를 사용해 애니메이션 완료 후 팝업 닫기
    }

    return Stack(
      children: [
        Positioned(
          left: adjustedLeft,
          top: adjustedTop,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: fadeOutAndClose, // ✅ 터치하면 서서히 사라짐
              borderRadius: BorderRadius.circular(17),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000), // ✅ 1초 동안 서서히 사라짐
                curve: Curves.easeInOut, // ✅ 부드러운 애니메이션 추가
                opacity: opacityLevel,
                onEnd: () { // 애니메이션이 끝난 후 실행됨
                  print("✅ Fade-out animation 완료 → 팝업 닫기 실행");
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop(); // ✅ 팝업 닫기
                  }
                },
                child: Container(
                  width: 220,
                  constraints: BoxConstraints(
                    minWidth: 150,
                    maxWidth: screenWidth * 0.6,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Colors.black,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          popupMessage,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  },
);
  },
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
