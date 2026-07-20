import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';

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
    final primary = energyMode
        ? const Color(0xFFD2CBF5)
        : const Color(0xFFB4EFF4);
    final secondary = energyMode
        ? const Color(0xFF82B9E2)
        : const Color(0xFF72B5DF);
    final accent = energyMode
        ? const Color(0xFF8494D7)
        : const Color(0xFF6388CB);

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
                    accent: accent,
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
                          color: secondary.withValues(alpha: 0.34),
                          blurRadius: 18,
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
    required this.accent,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;
  final Color accent;

  static const _stars = <Offset>[
    Offset(0.09, 0.28),
    Offset(0.18, 0.58),
    Offset(0.29, 0.18),
    Offset(0.38, 0.72),
    Offset(0.65, 0.2),
    Offset(0.75, 0.69),
    Offset(0.86, 0.34),
    Offset(0.93, 0.57),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value;
    final turn = phase * math.pi * 2;
    final scale = (size.width / 390).clamp(0.78, 1.12);
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = 78.0 * scale;
    final breath = 1 + math.sin(turn * 4) * 0.025;

    _drawSparseField(canvas, size, turn);
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
      alpha: 0.66,
      nodeRadius: 3.8 * scale,
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
      alpha: 0.44,
      nodeRadius: 3 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      motion: turn * 3 + 3.1,
      width: 286 * scale,
      height: 108 * scale,
      tilt: 0.27,
      color: accent,
      accentColor: primary,
      alpha: 0.4,
      nodeRadius: 2.4 * scale,
    );

    _drawFogCluster(canvas, center, radius, turn, breath);
    _drawEnergyRibbons(canvas, center, radius, turn);
    _drawLensHaze(canvas, center, radius);
  }

  void _drawSparseField(Canvas canvas, Size size, double turn) {
    for (var index = 0; index < _stars.length; index++) {
      final twinkle = (math.sin(turn * 2 + index * 1.83) + 1) / 2;
      final star = _stars[index];
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        0.55 + twinkle * 0.55,
        Paint()
          ..color = (index.isEven ? secondary : primary).withValues(
            alpha: 0.08 + twinkle * 0.24,
          ),
      );
    }
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
        secondary.withValues(alpha: 0.11),
        accent.withValues(alpha: 0.055),
        Colors.transparent,
      ],
      stops: const [0, 0.5, 1],
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
    required double nodeRadius,
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
            color.withValues(alpha: alpha * 0.18),
            accentColor.withValues(alpha: alpha * 0.24),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.68, 1],
        ).createShader(bounds),
    );

    for (var segment = 0; segment < 3; segment++) {
      final start = motion + segment * 2.094;
      final sweep = 0.48 - segment * 0.08;
      if (segment == 0) {
        canvas.drawArc(
          bounds,
          start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: alpha * 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
      canvas.drawArc(
        bounds,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.8 - segment * 0.85
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(
            color,
            accentColor,
            segment / 3,
          )!.withValues(alpha: alpha * (1 - segment * 0.18)),
      );
    }

    for (var trail = 5; trail >= 0; trail--) {
      final trailAngle = motion - trail * 0.05;
      final point = Offset(
        math.cos(trailAngle) * width / 2,
        math.sin(trailAngle) * height / 2,
      );
      final strength = 1 - trail / 6;
      canvas.drawCircle(
        point,
        nodeRadius * (0.32 + strength * 0.68),
        Paint()
          ..color = Color.lerp(
            color,
            Colors.white,
            strength * 0.32,
          )!.withValues(alpha: alpha * strength),
      );
    }
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
        primary.withValues(alpha: 0.24),
        secondary.withValues(alpha: 0.13),
        accent.withValues(alpha: 0.045),
        Colors.transparent,
      ],
      stops: const [0, 0.38, 0.7, 1],
    );
    _drawSoftEllipse(
      canvas,
      center + Offset(-fogRadius * 0.06, -fogRadius * 0.05),
      fogRadius * 1.08,
      xScale: 1.14,
      yScale: 0.86,
      colors: [
        const Color(0xFFEAF8FF).withValues(alpha: 0.3),
        primary.withValues(alpha: 0.2),
        secondary.withValues(alpha: 0.08),
        Colors.transparent,
      ],
      stops: const [0, 0.32, 0.68, 1],
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var band = 0; band < 4; band++) {
      canvas.save();
      canvas.rotate(turn * (band.isEven ? 1 : -1) + band * 0.72);
      final bandRadius = fogRadius * (0.46 + band * 0.16);
      final bounds = Rect.fromCircle(center: Offset.zero, radius: bandRadius);
      final color = Color.lerp(primary, secondary, band / 4)!;
      canvas.drawArc(
        bounds,
        0.3 + band * 0.42,
        1.18 - band * 0.1,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 18 - band * 2.7
          ..color = color.withValues(alpha: 0.09 + band * 0.012)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11),
      );
      canvas.restore();
    }
    canvas.restore();
  }

  void _drawEnergyRibbons(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var ribbon = 0; ribbon < 6; ribbon++) {
      final direction = ribbon.isEven ? 1.0 : -1.0;
      final cycles = 2 + ribbon % 3;
      final ribbonRadius = radius * (0.7 + ribbon * 0.11);
      final bounds = Rect.fromCircle(center: Offset.zero, radius: ribbonRadius);
      canvas.drawArc(
        bounds,
        turn * cycles * direction + ribbon * 1.02,
        0.62 + ribbon * 0.055,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.2 - ribbon * 0.24
          ..color = Color.lerp(
            primary,
            accent,
            ribbon / 7,
          )!.withValues(alpha: 0.56 - ribbon * 0.055),
      );
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
            secondary.withValues(alpha: 0.08),
            primary.withValues(alpha: 0.32),
            secondary.withValues(alpha: 0.08),
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
        secondary != oldDelegate.secondary ||
        accent != oldDelegate.accent;
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
        ..color = secondary.withValues(alpha: 0.1 + pulse * 0.1)
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
            secondary.withValues(alpha: 0.4),
            primary.withValues(alpha: 0.86),
            secondary.withValues(alpha: 0.4),
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
