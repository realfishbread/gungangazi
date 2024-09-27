import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class PopupHandler {
  final List<dynamic> listData;
  late VideoPlayerController _videoController;
  VideoPlayerController? _nextVideoController; // 미리 로드할 다음 비디오 컨트롤러
  String currentVideoPath = 'assets/person/jindan_move.mp4';

  PopupHandler({required this.listData}) {
    // 기본 비디오 초기화
    _videoController = VideoPlayerController.asset(currentVideoPath)
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
  void _changeVideo(String videoPath) async {
    if (videoPath == currentVideoPath) return; // 이미 같은 비디오가 재생 중이면 무시

    // 미리 다음 비디오를 준비 (백그라운드에서 초기화)
    _nextVideoController = VideoPlayerController.asset(videoPath);
    await _nextVideoController!.initialize();

    // 기존 비디오를 중단하고 미리 로드된 비디오로 전환
    _videoController.removeListener(_checkVideoEnd);
    _videoController.pause();
    _videoController.dispose();

    // 새 비디오로 변경
    _videoController = _nextVideoController!;
    currentVideoPath = videoPath;
    _videoController.setLooping(false);
    _videoController.play();
    _videoController.addListener(_checkVideoEnd);

    // 다음 비디오 컨트롤러를 null로 설정
    _nextVideoController = null;
  }

  // 팝업 띄우기 및 터치 좌표에 맞는 비디오 변경
  void showPopupForCoordinates(BuildContext context, Offset tapPosition, Function(String) onImageSelected) {
    String popupMessage = '';
    String newVideoPath = ''; // 터치한 부위에 맞는 비디오 경로

    // 화면 크기 가져오기
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // 터치 범위 조정: 머리와 다리 영역을 넓힘
    double headHeight = screenHeight * 0.30; // 머리 영역을 더 크게 (30%까지)
    double bodyHeight = screenHeight * 0.30; // 몸통 영역
    double legStartHeight = screenHeight * 0.55; // 다리 시작 높이 조정 (60%)
    double legEndHeight = screenHeight * 0.90; // 다리 끝 영역을 더 크게 (90%)
    double armWidth = screenWidth * 0.3; // 팔 영역

    // 좌표에 따른 구역 결정 및 비디오 경로 설정
    if (tapPosition.dy < headHeight) {
      popupMessage = '머리입니다. ';
      newVideoPath = 'assets/person/jindan_sad.mp4'; // 머리 비디오
    } else if (tapPosition.dy >= headHeight && tapPosition.dy < legStartHeight) {
      if (tapPosition.dx < armWidth || tapPosition.dx > (screenWidth - armWidth)) {
        popupMessage = '팔입니다.';
        newVideoPath = 'assets/person/arm_video.mp4'; // 팔 비디오
      } else {
        popupMessage = '몸통입니다. ';
        newVideoPath = 'assets/person/jindan_Stomach.mp4'; // 몸통 비디오
      }
    } else if (tapPosition.dy >= legStartHeight && tapPosition.dy < legEndHeight) {
      popupMessage = '다리입니다.';
      newVideoPath = 'assets/person/legs_video.mp4'; // 다리 비디오
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
          ? AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      )
          : const CircularProgressIndicator(), // 비디오 로딩 중 표시
    );
  }

  void dispose() {
    // 비디오 컨트롤러 해제
    _videoController.removeListener(_checkVideoEnd);
    _videoController.dispose();
    _nextVideoController?.dispose(); // 미리 로드한 비디오가 있으면 해제
  }
}
