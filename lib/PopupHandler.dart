import 'package:flutter/material.dart';
import 'dart:async';

class PopupHandler {
  final List<dynamic> listData;
  final Map<String, List<String>> imagePathsByBodyPart; // 부위별 이미지 경로 리스트
  int _currentImageIndex = 0; // 현재 이미지 인덱스
  late ValueNotifier<int> _imageNotifier; // 이미지 인덱스를 제어하는 ValueNotifier
  Timer? _imageTimer; // 이미지를 전환하는 타이머
  Duration frameDuration = const Duration(milliseconds: 500); // 이미지 프레임 전환 속도
  String _currentBodyPart = 'default'; // 현재 선택된 부위 ('head', 'body', 'arm', 'leg', 'default')

  // 기본 이미지 리스트 (애니메이션을 위해 여러 장)
  final List<String> defaultImagePaths = [
    'assets/person/jindan_sad1.jpg',
    'assets/person/jindan_sad2.jpg',
    'assets/person/jindan_sad3.jpg',
    'assets/person/jindan_sad4.jpg',
    'assets/person/jindan_sad5.jpg',
    'assets/person/jindan_sad6.jpg',
    'assets/person/jindan_sad7.jpg',
    'assets/person/jindan_sad8.jpg',
    'assets/person/jindan_sad9.jpg',
  ];

  // 이미지 경로 초기화
  PopupHandler({required this.listData})
      : imagePathsByBodyPart = {
    'head': [
      'assets/person/head1.jpg',
      'assets/person/head2.jpg',
      'assets/person/head3.jpg',
    ],
    'body': [
      'assets/person/body1.jpg',
      'assets/person/body2.jpg',
      'assets/person/body3.jpg',
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
    ],
  } {
    _imageNotifier = ValueNotifier<int>(_currentImageIndex);
  }

  // 이미지 전환을 시작
  void startImageAnimation() {
    _imageTimer = Timer.periodic(frameDuration, (timer) {
      if (_currentBodyPart == 'default') {
        _currentImageIndex = (_currentImageIndex + 1) % defaultImagePaths.length;
      } else {
        _currentImageIndex =
            (_currentImageIndex + 1) % imagePathsByBodyPart[_currentBodyPart]!.length;
      }
      _imageNotifier.value = _currentImageIndex; // 이미지 인덱스 업데이트
    });
  }

  // 이미지 전환을 중지
  void stopImageAnimation() {
    _imageTimer?.cancel();
  }

  // 팝업 띄우기 및 터치 좌표에 맞는 메시지 표시
  void showPopupForCoordinates(BuildContext context, Offset tapPosition, Function(String) onImageSelected) {
    String popupMessage = '';

    // 화면 크기 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // 터치 범위 조정: 머리와 다리 영역을 넓힘
    double headHeight = screenHeight * 0.30; // 머리 영역을 더 크게 (30%까지)
    double bodyHeight = screenHeight * 0.30; // 몸통 영역
    double legStartHeight = screenHeight * 0.55; // 다리 시작 높이 조정 (60%)
    double legEndHeight = screenHeight * 0.90; // 다리 끝 영역을 더 크게 (90%)
    double armWidth = screenWidth * 0.3; // 팔 영역

    // 좌표에 따른 구역 결정 및 메시지 설정
    if (tapPosition.dy < headHeight) {
      popupMessage = '머리입니다.';
      _currentBodyPart = 'head'; // 머리 이미지로 전환
    } else if (tapPosition.dy >= headHeight && tapPosition.dy < legStartHeight) {
      if (tapPosition.dx < armWidth || tapPosition.dx > (screenWidth - armWidth)) {
        popupMessage = '팔입니다.';
        _currentBodyPart = 'arm'; // 팔 이미지로 전환
      } else {
        popupMessage = '몸통입니다.';
        _currentBodyPart = 'body'; // 몸통 이미지로 전환
      }
    } else if (tapPosition.dy >= legStartHeight && tapPosition.dy < legEndHeight) {
      popupMessage = '다리입니다.';
      _currentBodyPart = 'leg'; // 다리 이미지로 전환
    }

    // 이미지 인덱스 초기화 및 애니메이션 시작
    _currentImageIndex = 0;
    _imageNotifier.value = _currentImageIndex;
    startImageAnimation();

    // 팝업에서 선택된 부위를 표시
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
                  : const Text('데이터가 없습니다.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  // 터치 이벤트와 이미지 애니메이션을 포함한 GestureDetector
  Widget buildImageAnimationWithTouch(BuildContext context, Function(String) onImageSelected) {
    startImageAnimation(); // 기본 이미지도 애니메이션 시작

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final tapPosition = details.localPosition;
        showPopupForCoordinates(context, tapPosition, onImageSelected);
      },
      child: ValueListenableBuilder<int>(
        valueListenable: _imageNotifier, // 이미지 인덱스를 감시하는 ValueNotifier
        builder: (context, value, child) {
          if (_currentBodyPart == 'default') {
            return Image.asset(
              defaultImagePaths[value], // 기본 이미지 애니메이션
              fit: BoxFit.cover,
            );
          } else {
            return Image.asset(
              imagePathsByBodyPart[_currentBodyPart]![value], // 선택된 부위의 이미지 표시
              fit: BoxFit.cover,
            );
          }
        },
      ),
    );
  }

  // 타이머와 관련된 리소스 해제
  void dispose() {
    stopImageAnimation();
  }
}

