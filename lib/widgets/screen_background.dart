import 'package:flutter/material.dart';
import 'package:syllables_apk/theme/app_theme.dart';

class ScreenBackground extends StatelessWidget {
  final String name;
  final Widget child;

  const ScreenBackground({
    super.key,
    required this.name,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppTheme.background),
        Positioned.fill(
          child: Image.asset(
            'assets/images/backgrounds/$name.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        child,
      ],
    );
  }
}
