import 'package:flutter/material.dart';

class DrawPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  DrawPoint(this.offset, this.color, [this.strokeWidth = 4.0]);
}
