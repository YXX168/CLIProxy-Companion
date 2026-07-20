import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';
import '../theme/app_theme.dart';

/// A compact first-sync signal made from two travelling light traces.
///
/// The painter deliberately avoids particles, rays and a solid orb. Vsync
/// drives the canvas directly, so the widget tree remains static while data is
/// loading and the animation stays smooth on high-refresh Android displays.
class SyncFlowLoader extends StatefulWidget {
  const SyncFlowLoader({required this.visualMode, super.key});

  final VisualMode visualMode;

  @override
  State<SyncFlowLoader> createState() => _SyncFlowLoaderState();
}

class _SyncFlowLoaderState extends State<SyncFlowLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_animationsDisabled == disabled) return;
    _animationsDisabled = disabled;
    if (disabled) {
      _controller
        ..stop()
        ..value = 0.18;
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energyMode = widget.visualMode == VisualMode.energy;
    final primary = energyMode ? AppTheme.violet : AppTheme.cyan;
    final secondary = energyMode ? AppTheme.cyan : AppTheme.magenta;

    return Semantics(
      liveRegion: true,
      label: '正在同步账户状态，请稍候',
      child: SizedBox(
        key: Key(energyMode ? 'energy-sync-flow' : 'console-sync-flow'),
        height: 468,
        child: Column(
          children: [
            SizedBox(
              key: const Key('sync-flow-field'),
              width: double.infinity,
              height: 342,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _SignalFlowPainter(
                    animation: _controller,
                    primary: primary,
                    secondary: secondary,
                  ),
                ),
              ),
            ),
            Text(
              '正在同步账户状态',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFF1F6FF),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                shadows: [
                  Shadow(color: primary.withValues(alpha: 0.3), blurRadius: 16),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '建立安全连接  ·  聚合账户能量',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8290A6),
                fontSize: 11,
                letterSpacing: 0.75,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 72,
              height: 8,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _SignalTicksPainter(
                    animation: _controller,
                    primary: primary,
                    secondary: secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalFlowPainter extends CustomPainter {
  _SignalFlowPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.54);
    final phase = animation.value * math.pi * 2;
    final pulse = (math.sin(phase) + 1) / 2;
    final halfWidth = math.min(size.width * 0.31, 132.0);
    final height = math.min(size.height * 0.34, 116.0);
    final bounds = Rect.fromCenter(
      center: center,
      width: halfWidth * 2.25,
      height: height * 1.7,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: halfWidth * (2.35 + pulse * 0.08),
        height: height * (1.05 + pulse * 0.04),
      ),
      Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.105),
            secondary.withValues(alpha: 0.038),
            Colors.transparent,
          ],
          stops: const [0, 0.48, 1],
        ).createShader(bounds)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final flow = _buildFlowPath(center, halfWidth, height);
    final flowShader = LinearGradient(
      colors: [
        secondary.withValues(alpha: 0.28),
        primary.withValues(alpha: 0.82),
        Colors.white.withValues(alpha: 0.7),
        primary.withValues(alpha: 0.82),
        secondary.withValues(alpha: 0.28),
      ],
    ).createShader(bounds);

    canvas.drawPath(
      flow,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = primary.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13),
    );
    canvas.drawPath(
      flow,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round
        ..shader = flowShader,
    );

    final metric = flow.computeMetrics().first;
    _drawTraveler(
      canvas,
      metric,
      animation.value,
      metric.length * 0.14,
      primary,
      bounds,
    );
    _drawTraveler(
      canvas,
      metric,
      (1 - animation.value + 0.48) % 1,
      metric.length * 0.1,
      secondary,
      bounds,
    );

    final beamRect = Rect.fromCenter(
      center: center,
      width: halfWidth * 1.05,
      height: 1,
    );
    canvas.drawLine(
      Offset(beamRect.left, center.dy),
      Offset(beamRect.right, center.dy),
      Paint()
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = primary.withValues(alpha: 0.12 + pulse * 0.035)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawLine(
      Offset(beamRect.left, center.dy),
      Offset(beamRect.right, center.dy),
      Paint()
        ..strokeWidth = 0.75
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            primary.withValues(alpha: 0.72),
            Colors.white.withValues(alpha: 0.9),
            primary.withValues(alpha: 0.72),
            Colors.transparent,
          ],
          stops: const [0, 0.32, 0.5, 0.68, 1],
        ).createShader(beamRect.inflate(1)),
    );

    _drawBeacon(canvas, center, phase, pulse);
    _drawAnchor(canvas, center.translate(-halfWidth, 0), primary, phase);
    _drawAnchor(canvas, center.translate(halfWidth, 0), secondary, -phase);
  }

  Path _buildFlowPath(Offset center, double halfWidth, double height) {
    final path = Path();
    const steps = 180;
    for (var index = 0; index <= steps; index++) {
      final angle = index / steps * math.pi * 2;
      final point = Offset(
        center.dx + halfWidth * math.sin(angle),
        center.dy + height * math.sin(angle) * math.cos(angle),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _drawTraveler(
    Canvas canvas,
    PathMetric metric,
    double progress,
    double length,
    Color color,
    Rect bounds,
  ) {
    final start = metric.length * progress;
    final paths = <Path>[];
    if (start + length <= metric.length) {
      paths.add(metric.extractPath(start, start + length));
    } else {
      paths
        ..add(metric.extractPath(start, metric.length))
        ..add(metric.extractPath(0, start + length - metric.length));
    }

    for (final path in paths) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.96),
              color.withValues(alpha: 0.65),
            ],
          ).createShader(bounds),
      );
    }
  }

  void _drawBeacon(Canvas canvas, Offset center, double phase, double pulse) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 4 + math.sin(phase) * 0.025);

    for (final entry in [(size: 58.0, alpha: 0.1), (size: 42.0, alpha: 0.2)]) {
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: entry.size,
        height: entry.size,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(11)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = primary.withValues(alpha: entry.alpha),
      );
    }

    final coreSize = 25 + pulse * 1.5;
    final coreRect = Rect.fromCenter(
      center: Offset.zero,
      width: coreSize,
      height: coreSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect.inflate(6), const Radius.circular(9)),
      Paint()
        ..color = primary.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(coreRect, const Radius.circular(7)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.94),
            primary.withValues(alpha: 0.9),
            secondary.withValues(alpha: 0.62),
          ],
        ).createShader(coreRect),
    );
    canvas.restore();

    canvas.drawCircle(
      center,
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
  }

  void _drawAnchor(Canvas canvas, Offset center, Color color, double phase) {
    final pulse = (math.sin(phase * 1.7) + 1) / 2;
    canvas.drawCircle(
      center,
      4 + pulse,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      center,
      1.35,
      Paint()..color = color.withValues(alpha: 0.88),
    );
  }

  @override
  bool shouldRepaint(covariant _SignalFlowPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}

class _SignalTicksPainter extends CustomPainter {
  _SignalTicksPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    const width = 14.0;
    const gap = 7.0;
    final left = (size.width - width * 3 - gap * 2) / 2;
    final phase = animation.value * math.pi * 2;
    for (var index = 0; index < 3; index++) {
      final energy = (math.sin(phase * 2 + index * math.pi * 0.72) + 1) / 2;
      final color = Color.lerp(primary, secondary, index / 2)!;
      final rect = Rect.fromLTWH(left + index * (width + gap), 2, width, 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(99)),
        Paint()
          ..color = color.withValues(alpha: 0.25 + energy * 0.7)
          ..maskFilter = energy > 0.7
              ? const MaskFilter.blur(BlurStyle.normal, 2)
              : null,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SignalTicksPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}
