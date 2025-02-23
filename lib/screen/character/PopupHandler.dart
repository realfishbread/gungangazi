

import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../core_services/dio_service.dart'; // DioService 추가
import '../../core_services/token_service.dart';
import '../../repositories/status/character_repository.dart';
import 'character_status.dart';
import 'character_image.dart';


class PopupHandler {
  final List<dynamic> listData;
  final DioService dioService; // DioService 인스턴스
  final TokenService tokenService; // TokenService 인스턴스

  int _currentImageIndex = 0;
  late ValueNotifier<int> _imageNotifier;
  Timer? _imageTimer;
  Duration frameDuration = const Duration(milliseconds: 300);
  String _currentBodyPart = 'default';
  int waterLevel = 100; // 수분 상태 변수 추가
  int mealLevel = 100;
  int sleepLevel = 100; // 수면 상태 변수

  final CharacterRepository _characterRepository =CharacterRepository();
  final CharacterStatus _characterStatus = CharacterStatus();

  final Map<String, List<String>> imagePathsByBodyPart = ImagePaths.imagePathsByBodyPart;

  
  
  final GlobalKey _imageKey = GlobalKey(); // 이미지를 위한 GlobalKey 선언
  Rect? _imageRect;

   void initialize() async{
      await _characterRepository.loadStatusFromServer();
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

  PopupHandler({
    required this.listData,
    required this.dioService,
    required this.tokenService,
  }) {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
    _characterRepository.loadStatusFromServer();
  }


  
  void updateStatus({required int newWaterLevel, required int newMealLevel, required int newSleepLevel}) {
    _characterStatus.updateStatus(newWaterLevel: newWaterLevel, newMealLevel: newMealLevel, newSleepLevel: newSleepLevel);
    setBodyPartStatus();
    startImageAnimation();
  }
   /// 서버에 현재 상태 저장





 


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
    
    return; // ✅ 이미 애니메이션이 실행 중이면 중복 실행 방지
  }
  
  
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
              _currentBodyPart = '0amdizzy'; 
            } 
        }else if(_currentBodyPart=='thirsty_and_hungry'){
          if (hour >= 22 || hour < 6) {
              _currentBodyPart = '0amheadache'; 
            } 
        }else if(_currentBodyPart =='thirsty_and_dizzy'){
          if (hour >= 22 || hour < 6) {
              _currentBodyPart = '0amheadache'; 
            } 
        }else if(_currentBodyPart=='thirsty'){
          if (hour >= 22 || hour < 6) {
              _currentBodyPart = '0amheadache'; 
            } 
        }else if(_currentBodyPart=='hungry'){
          if (hour >= 22 || hour < 6) {
              _currentBodyPart = '0amstomach'; 
            } 
        }else if(_currentBodyPart=='dizzy'){
          if (hour >= 22 || hour < 6) {
              _currentBodyPart = '0amtired'; 
            } 
        }
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
