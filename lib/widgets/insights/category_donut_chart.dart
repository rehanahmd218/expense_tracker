import 'package:flutter/material.dart';

import '../../providers/analytics_provider.dart';
import '../../theme/category_colors.dart';

class CategoryDonutChart extends StatelessWidget {
  const CategoryDonutChart({super.key, required this.slices});

  final List<CategorySlice> slices;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = slices.fold<double>(0, (s, x) => s + x.amount);
    final hasData = total > 0;

    return AspectRatio(
      aspectRatio: 1.05,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _DonutPainter(slices: slices, scheme: scheme),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasData
                        ? '\$${total % 1 == 0 ? total.toStringAsFixed(0) : total.toStringAsFixed(2)}'
                        : '—',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                  ),
                  Text(
                    'This month',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.scheme});

  final List<CategorySlice> slices;
  final ColorScheme scheme;

  static const _strokeWidth = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.shortestSide / 2 - _strokeWidth;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = scheme.surfaceContainerHighest;

    canvas.drawArc(rect, 0, 6.28318, false, trackPaint);

    final totalFraction = slices.fold<double>(0, (s, x) => s + x.fraction);
    if (totalFraction <= 0) return;

    var startAngle = -1.5708; // top
    for (final slice in slices) {
      if (slice.fraction <= 0) continue;
      final sweep = 6.28318 * slice.fraction;
      final color = slice.category.color(scheme);
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, startAngle, sweep, false, arcPaint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
