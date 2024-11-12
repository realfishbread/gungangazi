import 'MealPage.dart';
import 'SleepPage.dart';
import 'SupplementsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PopupHandler {
  final List<dynamic> listData;
  final Map<String, List<String>> imagePathsByBodyPart;
  int _currentImageIndex = 0;
  late ValueNotifier<int> _imageNotifier;
  Timer? _imageTimer;
  Duration frameDuration = const Duration(milliseconds: 250);
  String _currentBodyPart = 'default';
  int waterLevel = 100; // 수분 상태 변수 추가

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
  ];

  PopupHandler({required this.listData})
      : imagePathsByBodyPart = {
          'head': [
            'assets/person/jindan_sad.jpg',
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
          ],
          'arm': [
            'assets/person/jindan_armsick1.jpg',
            'assets/person/jindan_armsick2.jpg',
            'assets/person/jindan_armsick3.jpg',
            'assets/person/jindan_armsick4.jpg',
            'assets/person/jindan_armsick5.jpg',
            'assets/person/jindan_armsick6.jpg',
            'assets/person/jindan_armsick7.jpg',
            'assets/person/jindan_armsick8.jpg',
            'assets/person/jindan_armsick9.jpg',
            'assets/person/jindan_armsick10.jpg',
            'assets/person/jindan_armsick11.jpg',
            'assets/person/jindan_armsick12.jpg',
            'assets/person/jindan_armsick13.jpg',
            'assets/person/jindan_armsick16.jpg',
          ],
          'leg': [
            'assets/person/leg1.jpg',
            // 추가 이미지 경로
          ],
          'thirsty': [
            'assets/person/sad.jpg',
            'assets/person/sad1.jpg',
            'assets/person/sad2.jpg',
            'assets/person/sad3.jpg',
            'assets/person/sad4.jpg',
            'assets/person/sad5.jpg',
            'assets/person/sad6.jpg',
            'assets/person/sad7.jpg',
            'assets/person/sad8.jpg',
            'assets/person/sad9.jpg', 
          ],
        } {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
  }

  // 수분 상태에 따른 애니메이션 전환
  void updateWaterLevel(int newWaterLevel) {
    waterLevel = newWaterLevel;
    if (waterLevel <= 200) {
      _currentBodyPart = 'thirsty'; // 수분이 부족할 때 'thirsty' 애니메이션으로 전환
    } else {
      _currentBodyPart = 'default'; // 기본 상태로 복귀
    }
    startImageAnimation(); // 애니메이션 업데이트
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

  // 부위마다 다른 페이지로 이동하는 함수
  void _navigateToBodyPartPage(BuildContext context) {
    if (_currentBodyPart == 'head') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SleepPage()));
    } else if (_currentBodyPart == 'arm') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SupplementsPage()));
    } else if (_currentBodyPart == 'body') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MealPage()));
    } else if (_currentBodyPart == 'leg') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MealPage()));
    }
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

      // 부위별 팝업 메시지 설정
      if (relativeY < headHeight) {
        popupMessage = '머리가 아프신가요?';
        _currentBodyPart = 'head';
      } else if (relativeY >= headHeight && relativeY < legStartHeight) {
        if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
          popupMessage = '팔이 아프신가요?';
          _currentBodyPart = 'arm';
        } else {
          popupMessage = '몸이 아프신가요?';
          _currentBodyPart = 'body';
        }
      } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
        popupMessage = '다리가 아프신가요?';
        _currentBodyPart = 'leg';
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
                    _navigateToBodyPartPage(context);
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
