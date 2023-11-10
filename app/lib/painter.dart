import 'dart:ui';

import 'package:flutter/rendering.dart';

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}