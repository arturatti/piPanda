import 'package:flutter/material.dart';

enum MascotPose { idle, cheer, smile, think }

class Mascot extends StatelessWidget {
  final MascotPose pose;
  final double size;

  const Mascot({super.key, required this.pose, this.size = 160});

  String _file() {
    switch (pose) {
      case MascotPose.idle:
        return 'panda_idle.png';
      case MascotPose.cheer:
        return 'panda_cheer.png';
      case MascotPose.smile:
        return 'panda_smile.png';
      case MascotPose.think:
        return 'panda_think.png';
    }
  }

  String _fallbackEmoji() {
    switch (pose) {
      case MascotPose.idle:
        return '🐼';
      case MascotPose.cheer:
        return '🐼🎉';
      case MascotPose.smile:
        return '🐼✨';
      case MascotPose.think:
        return '🐼💭';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/mascot/${_file()}',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Center(
          child: Text(
            _fallbackEmoji(),
            style: TextStyle(fontSize: size * 0.55),
          ),
        ),
      ),
    );
  }
}
