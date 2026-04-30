import 'package:flutter/widgets.dart';

double tabletScale(BuildContext context) {
  final shortest = MediaQuery.of(context).size.shortestSide;
  if (shortest >= 840) return 1.6;
  if (shortest >= 600) return 1.35;
  return 1.0;
}

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

extension ResponsiveContext on BuildContext {
  double scale([double base = 1.0]) => base * tabletScale(this);
}
