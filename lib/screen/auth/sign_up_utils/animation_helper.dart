import 'package:flutter/material.dart';

class SlideAnimationHelper {
  final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;

  Animation<Offset> get slideAnimation => _slideAnimation;

  SlideAnimationHelper({required TickerProvider vsync, Duration duration = const Duration(seconds: 1)}) 
      : _animationController = AnimationController(vsync: vsync, duration: duration) {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // 위에서 시작
      end: Offset.zero, // 화면 중앙으로 이동
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void start() {
    _animationController.forward();
  }

  void dispose() {
    _animationController.dispose();
  }
}
