import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';
import '../theme/app_theme.dart';

/// A restrained first-sync scene built from fog, light ribbons and orbits.
///
/// Vsync drives both painters directly. The widget tree stays static while the
/// loading state is active, including on high-refresh Android displays.
class SyncOrbLoader extends StatefulWidget {
  const SyncOrbLoader({required this.visualMode, super.key});

  final VisualMode visualMode;

  @override
  State<SyncOrbLoader> createState() => _SyncOrbLoaderState();
}

class _SyncOrbLoaderState extends State<SyncOrbLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
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
        ..value = 0.137;
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
    final secondary = energyMode ? AppTheme.cyan : AppTheme.violet;

    return Semantics(
      liveRegion: true,
      label: '正在同步账户状态，请稍候',
      child: SizedBox(
        key: Key(energyMode ? 'energy-sync-orb' : 'console-sync-orb'),
        height: 535,
        child: Column(
          children: [
            SizedBox(
              key: const Key('sync-energy-field'),
              width: double.infinity,
              height: 420,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _FogSyncPainter(
                    animation: _controller,
                    primary: primary,
                    secondary: secondary,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -5),
              child: Column(
                children: [
                  Text(
                    '正在同步账户状态',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF1F6FF),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: primary.withValues(alpha: 0.52),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '建立安全连接  ·  聚合账户能量',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8795AA),
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 116,
                    height: 10,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _BreathingActivityPainter(
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
          ],
        ),
      ),
    );
  }
}

class _FogSyncPainter extends CustomPainter {
  _FogSyncPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value;
    final turn = phase * math.pi * 2;
    final scale = (size.width / 390).clamp(0.78, 1.12);
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = 78.0 * scale;
    final breath = 1 + math.sin(turn * 4) * 0.025;

    _drawAmbientFog(canvas, center, radius, breath);

    _drawOrbit(
      canvas,
      center,
      motion: turn * 4,
      width: 352 * scale,
      height: 136 * scale,
      tilt: -0.2,
      color: primary,
      accentColor: secondary,
      alpha: 0.92,
    );
    _drawOrbit(
      canvas,
      center,
      motion: -turn * 5 + 1.7,
      width: 274 * scale,
      height: 230 * scale,
      tilt: 0.68,
      color: secondary,
      accentColor: primary,
      alpha: 0.7,
    );

    _drawFogCluster(canvas, center, radius, turn, breath);
    _drawLensHaze(canvas, center, radius);
  }

  void _drawAmbientFog(
    Canvas canvas,
    Offset center,
    double radius,
    double breath,
  ) {
    _drawSoftEllipse(
      canvas,
      center,
      radius * 2.34 * breath,
      xScale: 1.18,
      yScale: 0.82,
      colors: [
        primary.withValues(alpha: 0.34),
        secondary.withValues(alpha: 0.2),
        Colors.transparent,
      ],
      stops: const [0, 0.52, 1],
    );
  }

  void _drawOrbit(
    Canvas canvas,
    Offset center, {
    required double motion,
    required double width,
    required double height,
    required double tilt,
    required Color color,
    required Color accentColor,
    required double alpha,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);
    final bounds = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    canvas.drawOval(
      bounds,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..shader = SweepGradient(
          transform: GradientRotation(motion * 0.18),
          colors: [
            Colors.transparent,
            color.withValues(alpha: alpha * 0.24),
            accentColor.withValues(alpha: alpha * 0.32),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.68, 1],
        ).createShader(bounds),
    );

    const sweep = 0.82;
    canvas.drawArc(
      bounds,
      motion,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: alpha * 0.22)
        ..blendMode = BlendMode.plus
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawArc(
      bounds,
      motion,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = Color.lerp(
          color,
          Colors.white,
          0.16,
        )!.withValues(alpha: alpha)
        ..blendMode = BlendMode.plus,
    );
    canvas.restore();
  }

  void _drawFogCluster(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
    double breath,
  ) {
    final fogRadius = radius * breath;
    _drawSoftEllipse(
      canvas,
      center,
      fogRadius * 1.5,
      xScale: 1.08,
      yScale: 0.92,
      colors: [
        primary.withValues(alpha: 0.58),
        secondary.withValues(alpha: 0.34),
        Colors.transparent,
      ],
      stops: const [0, 0.48, 1],
    );
    _drawSoftEllipse(
      canvas,
      center,
      fogRadius * 1.18,
      xScale: 1.12,
      yScale: 0.88,
      colors: [
        Colors.white.withValues(alpha: 0.34),
        primary.withValues(alpha: 0.82),
        primary.withValues(alpha: 0.22),
        Colors.transparent,
      ],
      stops: const [0, 0.27, 0.64, 1],
    );
    _drawSoftEllipse(
      canvas,
      center + Offset(fogRadius * 0.1, fogRadius * 0.03),
      fogRadius,
      xScale: 1.2,
      yScale: 0.78,
      colors: [
        secondary.withValues(alpha: 0.42),
        primary.withValues(alpha: 0.12),
        Colors.transparent,
      ],
      stops: const [0, 0.52, 1],
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var band = 0; band < 2; band++) {
      canvas.save();
      canvas.rotate(turn * (band.isEven ? 1 : -1) + band * 0.72);
      final bandRadius = fogRadius * (0.54 + band * 0.22);
      final bounds = Rect.fromCircle(center: Offset.zero, radius: bandRadius);
      final color = Color.lerp(primary, secondary, band / 2)!;
      canvas.drawArc(
        bounds,
        0.3 + band * 0.58,
        1.28 - band * 0.18,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 22 - band * 4
          ..color = color.withValues(alpha: 0.22 + band * 0.04)
          ..blendMode = BlendMode.plus
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  void _drawLensHaze(Canvas canvas, Offset center, double radius) {
    final lineRect = Rect.fromCenter(
      center: center,
      width: radius * 2.7,
      height: 1,
    );
    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            secondary.withValues(alpha: 0.16),
            primary.withValues(alpha: 0.68),
            secondary.withValues(alpha: 0.16),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.5, 0.72, 1],
        ).createShader(lineRect),
    );
  }

  void _drawSoftEllipse(
    Canvas canvas,
    Offset center,
    double radius, {
    required double xScale,
    required double yScale,
    required List<Color> colors,
    required List<double> stops,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(xScale, yScale);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FogSyncPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}

class _BreathingActivityPainter extends CustomPainter {
  _BreathingActivityPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final pulse =
        (math.sin(animation.value * math.pi * 8 - math.pi / 2) + 1) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final halfLength = 18 + pulse * 28;
    final start = center - Offset(halfLength, 0);
    final end = center + Offset(halfLength, 0);

    canvas.drawLine(
      start,
      end,
      Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = secondary.withValues(alpha: 0.16 + pulse * 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    final lineRect = Rect.fromPoints(start, end).inflate(1);
    canvas.drawLine(
      start,
      end,
      Paint()
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            secondary.withValues(alpha: 0.62),
            primary.withValues(alpha: 0.96),
            secondary.withValues(alpha: 0.62),
            Colors.transparent,
          ],
          stops: const [0, 0.25, 0.5, 0.75, 1],
        ).createShader(lineRect),
    );
    canvas.drawCircle(
      center,
      1.4 + pulse * 0.7,
      Paint()..color = primary.withValues(alpha: 0.58 + pulse * 0.34),
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingActivityPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}
