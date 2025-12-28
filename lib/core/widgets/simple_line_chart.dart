import 'package:flutter/material.dart';

class SimpleLineChart extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final double height;

  const SimpleLineChart({super.key, required this.data, this.lineColor = Colors.white, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, progress, child) {
          return CustomPaint(
            painter: _LineChartPainter(data: data, lineColor: lineColor, progress: progress),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final double progress;

  _LineChartPainter({required this.data, required this.lineColor, this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    if (data.isEmpty) return;

    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = (max - min) == 0 ? 1 : (max - min);

    final stepX = size.width / (data.length - 1);

    final path = Path();
    // Build full list of points
    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = stepX * i;
      final y = size.height - ((data[i] - min) / range) * size.height;
      points.add(Offset(x, y));
    }

    // Determine how many segments to draw based on progress
    final totalSegments = (points.length - 1).clamp(1, points.length - 1);
    final target = progress * totalSegments;
    final intSegments = target.floor();
    final frac = target - intSegments;

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (var i = 1; i <= intSegments; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      if (intSegments + 1 < points.length && frac > 0) {
        final p0 = points[intSegments];
        final p1 = points[intSegments + 1];
        final interp = Offset(
          p0.dx + (p1.dx - p0.dx) * frac,
          p0.dy + (p1.dy - p0.dy) * frac,
        );
        path.lineTo(interp.dx, interp.dy);
      }
    }

    // area under curve (fill)
    final areaPath = Path.from(path);
    areaPath.lineTo(path.getBounds().right, size.height);
    areaPath.lineTo(path.getBounds().left, size.height);
    areaPath.close();
    final fillPaint = Paint()
      ..color = lineColor.withAlpha((0.12 * 255).round())
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, fillPaint);

    // shadow
    final shadowPaint = Paint()
      ..color = lineColor.withAlpha((0.18 * 255).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // draw circles at visible points
    final dotPaint = Paint()..color = Colors.white;
    final dotBorder = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (var i = 0; i < points.length; i++) {
      final px = points[i];
      // check if this point is within progress
      final segIndex = i;
      if (segIndex <= intSegments || (segIndex == intSegments + 1 && frac > 0 && i == intSegments + 1)) {
        canvas.drawCircle(px, 3.5, dotPaint);
        canvas.drawCircle(px, 3.5, dotBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
