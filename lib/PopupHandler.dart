import 'package:example4/MealPage.dart';
import 'package:example4/SleepPage.dart';
import 'package:example4/SupplementsPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PopupHandler {
  final List<dynamic> listData;
  final Map<String, List<String>> imagePathsByBodyPart;
  int _currentImageIndex = 0;
  late ValueNotifier<int> _imageNotifier;
  Timer? _imageTimer;
  Duration frameDuration = const Duration(milliseconds: 500);
  String _currentBodyPart = 'default';

  Rect? _imageRect; // 이미지의 위치와 크기를 저장
  final GlobalKey _imageKey = GlobalKey(); // 이미지를 위한 GlobalKey 선언

  // 기본 이미지 리스트 (애니메이션을 위해 여러 장)
  final List<String> defaultImagePaths = [
    'assets/person/jindan_N1.jpg',
    'assets/person/jindan_N3.jpg',
    'assets/person/jindan_N5.jpg',
  ];

  PopupHandler({required this.listData})
      : imagePathsByBodyPart = {
    'head': [
      'assets/person/jindan_sad1.jpg',
      'assets/person/jindan_sad2.jpg',
    ],
    'body': [
      'assets/person/jindan_stomach1.jpg',
      'assets/person/jindan_stomach2.jpg',
    ],
    'arm': [
      'assets/person/jindan_armsick1.jpg',
      'assets/person/jindan_armsick3.jpg',
    ],
    'leg': [
      'assets/person/leg1.jpg',
      'assets/person/leg2.jpg',
    ],
  } {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
  }

  // 이미지 애니메이션 시작
  void startImageAnimation() {
    _imageTimer = Timer.periodic(frameDuration, (timer) {
      if (_currentBodyPart == 'default') {
        _currentImageIndex = (_currentImageIndex + 1) % defaultImagePaths.length;
      } else {
        _currentImageIndex =
            (_currentImageIndex + 1) % imagePathsByBodyPart[_currentBodyPart]!.length;
      }
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
      Offset position = box.localToGlobal(Offset.zero); // 이미지의 위치
      Size size = box.size; // 이미지의 크기
      _imageRect = position & size; // 위치와 크기를 Rect로 저장
    }
  }

  // 부위마다 다른 페이지로 이동하는 함수
  void _navigateToBodyPartPage(BuildContext context) {
    if (_currentBodyPart == 'head') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SleepPage()));
    } else if (_currentBodyPart == 'arm') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SupplementsPage()));
    } else if (_currentBodyPart == 'body') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MealPage()));
    } else if (_currentBodyPart == 'leg') {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MealPage()));
    }
  }

  // 터치된 좌표에 맞는 팝업 표시
  void showPopupForCoordinates(
      BuildContext context, Offset tapPosition, Function(String) onImageSelected) {
    if (_imageRect == null) return; // 이미지 크기가 설정되지 않은 경우 무시

    String popupMessage = '';

    // 터치가 이미지 범위 내에 있는지 확인
    if (_imageRect!.contains(tapPosition)) {
      double relativeY = tapPosition.dy - _imageRect!.top;
      double relativeX = tapPosition.dx - _imageRect!.left;

      double imageHeight = _imageRect!.height;
      double imageWidth = _imageRect!.width;

      double headHeight = imageHeight * 0.30;
      double bodyHeight = imageHeight * 0.30;
      double legStartHeight = imageHeight * 0.55;
      double legEndHeight = imageHeight * 0.90;
      double armWidth = imageWidth * 0.3;

      // 부위별 팝업 메시지 설정
      if (relativeY < headHeight) {
        popupMessage = '머리입니다.';
        _currentBodyPart = 'head';
      } else if (relativeY >= headHeight && relativeY < legStartHeight) {
        if (relativeX < armWidth || relativeX > (imageWidth - armWidth)) {
          popupMessage = '팔입니다.';
          _currentBodyPart = 'arm';
        } else {
          popupMessage = '몸통입니다.';
          _currentBodyPart = 'body';
        }
      } else if (relativeY >= legStartHeight && relativeY < legEndHeight) {
        popupMessage = '다리입니다.';
        _currentBodyPart = 'leg';
      }

      // 이미지 전환 애니메이션 시작
      _currentImageIndex = 0;
      _imageNotifier.value = _currentImageIndex;
      startImageAnimation();

      // 팝업 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('선택된 영역'),
            content: Column(
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
                    : const SizedBox(), // 데이터가 없을 때는 빈 위젯으로 대체
              ],
            ),
            actions: [
              Center( // 버튼을 중앙에 배치
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToBodyPartPage(context); // 부위에 맞는 페이지로 이동
                  },
                  child: const Text('다른 페이지로 이동'),
                ),
              ),
            ],
          );
        },
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
            _calculateImageRect(); // 이미지 렌더링 후 위치와 크기 계산
            final tapPosition = details.globalPosition; // globalPosition 사용
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
                key: _imageKey, // GlobalKey를 사용하여 이미지 위치 계산
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

// 예시로 사용할 다른 페이지
class AnotherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("다른 페이지")),
      body: Center(child: const Text("다른 페이지 내용")),
    );
  }
}
