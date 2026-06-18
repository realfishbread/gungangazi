import 'package:flutter/material.dart';
import 'package:gunganghazi/view_model/character_view_model.dart';
// ✅ Provider 추가
import 'package:provider/provider.dart';

import '../../repositories/status/character_repository.dart';
import 'character_status_service.dart';

// 유저 터치 감지, 팝업 띄우기
class PopupHandler {
  Duration frameDuration = const Duration(milliseconds: 300);

  final CharacterRepository _characterRepository = CharacterRepository();
  final CharacterStatusService characterStatusService =
      CharacterStatusService();

  final GlobalKey imageKey;

  final CharacterViewModel characterViewModel;
  PopupHandler({required this.characterViewModel, required this.imageKey});

  Rect? _imageRect;

  // 이미지의 위치 및 크기를 계산하는 함수
  void _calculateImageRect() {
    final context = imageKey.currentContext;
    if (context == null) {
      print('❌ currentContext 없음');
      return;
    }

    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset position = box.localToGlobal(Offset.zero);
      final Size size = box.size;
      _imageRect = position & size;
      print('🟢 이미지 위치 계산 완료: $_imageRect');
    } else {
      print('❌ RenderBox 못 찾음');
    }
  }

  Widget buildImageAnimationWithTouch(
    BuildContext context,
    Function(String) onImageSelected,
  ) {
    final viewModel = context.read<CharacterViewModel>();
    final popupHandler = viewModel.popupHandler;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (TapDownDetails details) {
            final tapPosition = details.globalPosition;
            popupHandler.showPopupForCoordinates(
              context,
              tapPosition,
              onImageSelected,
              viewModel,
            );
          },
          child: ValueListenableBuilder<int>(
            valueListenable: viewModel.imageIndex,
            builder: (context, value, child) {
              return Image.asset(
                viewModel.currentImages[value],
                key: viewModel.imageKey,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              );
            },
          ),
        );
      },
    );
  }

  // 터치 이벤트 및 팝업
  void showPopupForCoordinates(
    BuildContext context,
    Offset tapPosition,
    Function(String) onImageSelected,
    CharacterViewModel characterViewModel,
  ) {
    print('📌 currentBodyPartKey: ${characterViewModel.currentBodyPartKey}');
    _calculateImageRect();
    if (_imageRect == null) {
      print('❌ 이미지 위치 계산 실패');
      return;
    }

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

      // 메시지 결정 (상태에 따라)
      final statusKey = characterViewModel.currentBodyPartKey;

      // 물 부족 상태일 때 팝업 메시지 설정
      if (statusKey == 'thirsty') {
        popupMessage = '목이 말라요... \n물을 주세요!';
      } else if (statusKey == 'hungry') {
        popupMessage = '배고파요... \n식사를 해주세요!!';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고,\n배가 고파요';
          } else {
            popupMessage = '수분섭취를\n잊지 말아주세요';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
        }
      } else if (statusKey == 'thirsty_and_dizzy') {
        popupMessage = '충분한 숙면을 \n취하지 못했어요,\n목도 말라요.';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고,\n배가 고파요';
          } else {
            popupMessage = '수분섭취를 잊지 말아주세요';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
        }
      } else if (statusKey == 'thirsty_and_hungry_dizzy') {
        popupMessage = '건강을 챙겨주세요';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, \n배가 고파요';
          } else {
            popupMessage = '수분 섭취를\n잊지 말아주세요';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
        }
      } else if (statusKey == 'thirsty_and_hungry') {
        popupMessage = '목도 마르고 \n배도 고파요,\n 물과 식사가 필요해요!';
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '식사를 잘 챙겨주세요!';
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '목을 축이고 싶고, \n배가 고파요';
          } else {
            popupMessage = '수분섭취를\n잊지 말아주세요';
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '배고파서 삭신이 쑤셔요.';
        }
      } else if (statusKey == 'hungry_and_dizzy') {
        popupMessage = '충분한 숙면과\n밥을 챙겨주세요';
      } else if (statusKey == '0am') {
        popupMessage = '좋은 꿈꾸세요!';
        if (relativeY < headHeight) {
          popupMessage = '주무실 시간이네요!';
          characterViewModel.triggerAnimation('0amhead');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '오늘의 파자마는\n 보라색이예요.';
            characterViewModel.triggerAnimation('0amarm');
          } else {
            popupMessage = '오늘은 \n어떤 하루였나요?';
            characterViewModel.triggerAnimation('0amtouch');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '오늘 하루도 \n수고 많으셨어요.';
          characterViewModel.triggerAnimation('0amtouch');
        }
      } else if (statusKey == '0amstomach') {
        popupMessage = '몸을 조금 \n더 챙겨주세요.';
        if (relativeY < headHeight) {
          popupMessage = '집가서 자고 싶어요.';
          characterViewModel.triggerAnimation('0amstomach');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '피곤해요';
            characterViewModel.triggerAnimation('0amstomach');
          } else {
            popupMessage = '피곤해요';
            characterViewModel.triggerAnimation('0amstomach');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '주무셔야 해요.';
          characterViewModel.triggerAnimation('0amtouch');
        }
      } else if (statusKey == '0amddong') {
        popupMessage = '배가 \n 꼬르륵거려요.';
        if (relativeY < headHeight) {
          popupMessage = '식사를 챙겨주세요!';
          characterViewModel.triggerAnimation('0amddong');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '수분이 부족해요.';
            characterViewModel.triggerAnimation('0amddong');
          } else {
            popupMessage = '충분한 식사와 \n 수분이 필요해요';
            characterViewModel.triggerAnimation('0amddong');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '식사를 하시면 \n 제가 기쁠거예요.';
          characterViewModel.triggerAnimation('0amddong');
        }
      } else if (statusKey == '0amtired') {
        popupMessage = '배가 \n 꼬르륵거려요.';
        if (relativeY < headHeight) {
          popupMessage = '식사를 챙겨주세요!';
          characterViewModel.triggerAnimation('0amtired');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '수분이 부족해요.';
            characterViewModel.triggerAnimation('0amtired');
          } else {
            popupMessage = '충분한 식사와 \n 수분이 필요해요';
            characterViewModel.triggerAnimation('0amtired');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '식사를 하시면 \n 제가 기쁠거예요.';
          characterViewModel.triggerAnimation('0amtired');
        }
      } else if (statusKey == '0amheadache') {
        popupMessage = '배가 \n 꼬르륵거려요.';
        if (relativeY < headHeight) {
          popupMessage = '식사를 챙겨주세요!';
          characterViewModel.triggerAnimation('0amheadache');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '수분이 부족해요.';
            characterViewModel.triggerAnimation('0amheadache');
          } else {
            popupMessage = '충분한 식사와 \n 수분이 필요해요';
            characterViewModel.triggerAnimation('0amheadache');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '식사를 하시면 \n 제가 기쁠거예요.';
          characterViewModel.triggerAnimation('0amheadache');
        }
      } else if (statusKey == '0amdizzy') {
        popupMessage = '건강을 챙겨주세요.';
        if (relativeY < headHeight) {
          popupMessage = '충분한 수분을 섭취후,\n 기록해 주세요.';
          characterViewModel.triggerAnimation('0amdizzy');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '식사가 없으면 \n 몸이 망가져요.';
            characterViewModel.triggerAnimation('0amdizzy');
          } else {
            popupMessage = '충분한 식사와 \n 수면이 필요해요';
            characterViewModel.triggerAnimation('0amdizzy');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '몸을 챙겨주시면 기쁠거예요.';
          characterViewModel.triggerAnimation('0amdizzy');
        }
      } else if (statusKey == 'dizzy') {
        popupMessage = '수면 시간을 늘려주세요!';
      } else {
        // 부위별 팝업 메시지 설정
        if (relativeY < headHeight) {
          popupMessage = '잘 주무셨나요?';
          characterViewModel.triggerAnimation('head');
        } else if (relativeY >= headHeight && relativeY < legStartHeight) {
          if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
            popupMessage = '오늘 하루도 화이팅!';
            characterViewModel.triggerAnimation('arm');
          } else {
            popupMessage = '식사 하셨나요?';
            characterViewModel.triggerAnimation('waist');
          }
        } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
          popupMessage = '화이팅!';
          characterViewModel.triggerAnimation('smile');
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
                          duration: const Duration(
                              milliseconds: 1000), // ✅ 1초 동안 서서히 사라짐
                          curve: Curves.easeInOut, // ✅ 부드러운 애니메이션 추가
                          opacity: opacityLevel,
                          onEnd: () {
                            // 애니메이션이 끝난 후 실행됨

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
}
