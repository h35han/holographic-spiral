import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OffsetMarker extends StatelessWidget {
  const OffsetMarker({
    super.key,
    required this.value,
    this.child,
    this.color = const Color(0xFFFF00FF),
    this.correction = Offset.zero,
  });

  final Offset value;
  final Offset correction;
  final Widget? child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: OffsetMarkerPainter(
        value + correction,
        color: color,
      ),
      child: child,
    );
  }
}

class OffsetMarkerPainter extends CustomPainter {
  OffsetMarkerPainter(this.value, {required this.color});

  final Offset value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = color;

    final dx = value.dx * size.width;
    final dy = value.dy * size.height;

    canvas.drawLine(Offset(0.0, dy), Offset(size.width, dy), paint);
    canvas.drawLine(Offset(dx, 0.0), Offset(dx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
