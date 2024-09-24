import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class PopupHandler {
  final List<dynamic> listData;
  late VideoPlayerController _videoController;

  PopupHandler({required this.listData}) {
    // 기본 비디오 초기화
    _videoController = VideoPlayerController.asset('assets/person/jindan_move.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(false); // 루프 대신 수동으로 반복 처리
        _videoController.play();
        _videoController.addListener(_checkVideoEnd); // 비디오 끝 체크
      });
  }

  // 비디오가 끝났을 때 2초 지연 후 다시 재생
  void _checkVideoEnd() {
    if (_videoController.value.position == _videoController.value.duration) {
      // 비디오가 끝났으면 2초 대기 후 재생
      Future.delayed(const Duration(seconds: 2), () {
        _videoController.seekTo(Duration.zero); // 처음으로 이동
        _videoController.play(); // 다시 재생
      });
    }
  }

  // 비디오 변경 함수
  void _changeVideo(String videoPath) {
    // 이전 비디오 컨트롤러 dispose
    _videoController.dispose();

    // 새 비디오 컨트롤러 설정
    _videoController = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        _videoController.setLooping(false); // 루프 대신 수동으로 반복 처리
        _videoController.play();
        _videoController.addListener(_checkVideoEnd); // 비디오 끝 체크
      });
  }

  void showPopupForCoordinates(BuildContext context, Offset tapPosition, Function(String) onImageSelected) {
    String popupMessage = '';
    String newVideoPath = ''; // 터치한 부위에 맞는 비디오 경로

    // 화면 크기 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // 캐릭터 이미지의 부위별 영역 나누기
    double headHeight = screenHeight * 0.25; // 머리 영역
    double bodyHeight = screenHeight * 0.4; // 몸통 영역
    double legStartHeight = screenHeight * 0.65; // 다리 시작 지점
    double armWidth = screenWidth * 0.3; // 팔 영역

    // 좌표에 따른 구역 결정 및 비디오 경로 설정
    if (tapPosition.dy < headHeight) {
      popupMessage = '머리입니다. 어디가 안좋은가요?';
      newVideoPath = 'assets/person/head_video.mp4'; // 머리 비디오
    } else if (tapPosition.dy >= headHeight && tapPosition.dy < legStartHeight) {
      if (tapPosition.dx < armWidth) {
        popupMessage = '왼쪽 팔입니다. 어디가 안좋은가요?';
        newVideoPath = 'assets/person/left_arm_video.mp4'; // 왼팔 비디오
      } else if (tapPosition.dx > (screenWidth - armWidth)) {
        popupMessage = '오른쪽 팔입니다. 어디가 안좋은가요?';
        newVideoPath = 'assets/person/right_arm_video.mp4'; // 오른팔 비디오
      } else {
        popupMessage = '몸통입니다. 어디가 안좋은가요?';
        newVideoPath = 'assets/person/jindan_Stomach.mp4'; // 몸통 비디오
      }
    } else if (tapPosition.dy >= legStartHeight && tapPosition.dy < screenHeight * 0.85) {
      popupMessage = '다리입니다. 어디가 안좋은가요?';
      newVideoPath = 'assets/person/legs_video.mp4'; // 다리 비디오
    } else {
      popupMessage = '발입니다. 어디가 안좋은가요?';
      newVideoPath = 'assets/person/feet_video.mp4'; // 발 비디오
    }

    // 비디오 변경
    _changeVideo(newVideoPath);

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

  // 비디오를 포함한 GestureDetector
  Widget buildVideoWithTouch(BuildContext context, Function(String) onImageSelected) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final tapPosition = details.localPosition;
        showPopupForCoordinates(context, tapPosition, onImageSelected);
      },
      child: _videoController.value.isInitialized
          ? Transform.rotate(
        angle: 0, // 각도를 0으로 설정하여 원래 방향을 유지합니다 (필요시 각도 조정 가능).
        child: AspectRatio(
          aspectRatio: _videoController.value.aspectRatio,
          child: VideoPlayer(_videoController),
        ),
      )
          : const CircularProgressIndicator(), // 비디오 로딩 중 표시
    );
  }

  void dispose() {
    // 비디오 컨트롤러 해제
    _videoController.dispose();
  }
}
