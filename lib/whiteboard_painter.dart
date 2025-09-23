import 'package:flutter/material.dart';
import 'draw_point.dart';
import 'detected_square.dart';

class WhiteboardPainter extends CustomPainter {
  final List<DrawPoint?> points;
  final List<DetectedSquare> squares;

  WhiteboardPainter(this.points, [this.squares = const []]);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        Paint paint = Paint()
          ..color = points[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i]!.strokeWidth;
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, paint);
      }
    }
    for (var square in squares) {
      Paint paint = Paint()
        ..color = square.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawRect(square.rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
