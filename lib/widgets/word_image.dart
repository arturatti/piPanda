import 'package:flutter/material.dart';
import 'package:syllables_apk/theme/app_theme.dart';
import 'package:syllables_apk/utils/responsive.dart';

class WordImage extends StatelessWidget {
  final String imageFile;
  final String fallbackText;
  final double baseSize;
  final bool applyScale;

  const WordImage({
    super.key,
    required this.imageFile,
    required this.fallbackText,
    this.baseSize = 200,
    this.applyScale = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = applyScale ? baseSize * tabletScale(context) : baseSize;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/words/$imageFile',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _Placeholder(text: fallbackText, size: size),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String text;
  final double size;

  const _Placeholder({required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.softYellow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary, width: 2),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 48, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
