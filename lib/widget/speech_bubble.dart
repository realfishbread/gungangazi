import 'package:flutter/material.dart';

void showSpeechBubble(BuildContext context, Offset position, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry; // <- 여기서 late로 선언

  overlayEntry = OverlayEntry(
    builder: (context) {
      double opacity = 1.0;
      return StatefulBuilder(
        builder: (context, setState) {
          return Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  opacity = 0.0;
                });
              },
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: opacity,
                onEnd: () {
                  overlayEntry.remove(); // 🔥 이제 문제 없음!
                },
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );

  overlay.insert(overlayEntry);
}