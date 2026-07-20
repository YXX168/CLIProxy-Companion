import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';

/// A flowing first-sync scene inspired by Pulsar's soft light clusters.
///
/// The animation is driven directly by vsync, so high-refresh displays can
/// paint at their native cadence. Only the two CustomPainters repaint.
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
      duration: const Duration(seconds: 12),
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
        ? const Color(0xFFA98CFF)
        : const Color(0xFF72ECF8);
    final secondary = energyMode
        ? const Color(0xFF5DE2F4)
        : const Color(0xFF6D86FF);

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
                  painter: _HyperSyncPainter(
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
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      shadows: [
                        Shadow(
                          color: primary.withValues(alpha: 0.58),
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
                      color: const Color(0xFF8795AE),
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: 156,
                    height: 12,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _VelocityIndicatorPainter(
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

class _HyperSyncPainter extends CustomPainter {
  _HyperSyncPainter({
    required this.animation,
    required this.primary,
    required this.secondary,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color primary;
  final Color secondary;

  static const _stars = <Offset>[
    Offset(0.05, 0.18),
    Offset(0.09, 0.48),
    Offset(0.13, 0.31),
    Offset(0.18, 0.68),
    Offset(0.23, 0.12),
    Offset(0.27, 0.42),
    Offset(0.32, 0.76),
    Offset(0.37, 0.22),
    Offset(0.43, 0.61),
    Offset(0.48, 0.09),
    Offset(0.55, 0.73),
    Offset(0.61, 0.18),
    Offset(0.66, 0.54),
    Offset(0.72, 0.08),
    Offset(0.76, 0.72),
    Offset(0.81, 0.29),
    Offset(0.86, 0.59),
    Offset(0.91, 0.16),
    Offset(0.95, 0.43),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = animation.value;
    final turn = phase * math.pi * 2;
    final scale = (size.width / 390).clamp(0.78, 1.12);
    final center = Offset(size.width / 2, size.height * 0.6);
    final coreRadius = 76.0 * scale;
    final breath = 1 + math.sin(turn * 2) * 0.035;

    _drawStarField(canvas, size, turn);
    _drawAmbientEnergy(canvas, center, coreRadius, breath);
    _drawRadialVelocityRays(canvas, center, coreRadius, turn);
    _drawParticleFlow(canvas, center, coreRadius, turn);

    _drawOrbit(
      canvas,
      center,
      motion: turn * 3,
      width: 350 * scale,
      height: 132 * scale,
      tilt: -0.24,
      color: primary,
      accent: secondary,
      alpha: 0.78,
      nodeRadius: 4.5 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      motion: -turn * 4 + 1.7,
      width: 270 * scale,
      height: 226 * scale,
      tilt: 0.72,
      color: secondary,
      accent: primary,
      alpha: 0.55,
      nodeRadius: 3.6 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      motion: turn * 2 + 3.1,
      width: 250 * scale,
      height: 98 * scale,
      tilt: 0.28,
      color: primary,
      accent: Colors.white,
      alpha: 0.46,
      nodeRadius: 2.8 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      motion: -turn * 2 + 4.2,
      width: 338 * scale,
      height: 205 * scale,
      tilt: -0.64,
      color: secondary,
      accent: primary,
      alpha: 0.3,
      nodeRadius: 2.2 * scale,
    );

    _drawCore(canvas, center, coreRadius, turn, breath);
    _drawCoreStreams(canvas, center, coreRadius, turn);
    _drawForegroundFlares(canvas, center, coreRadius, turn);
  }

  void _drawStarField(Canvas canvas, Size size, double turn) {
    for (var index = 0; index < _stars.length; index++) {
      final star = _stars[index];
      final twinkle = (math.sin(turn * (2 + index % 3) + index * 1.71) + 1) / 2;
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        0.45 + twinkle * (index % 5 == 0 ? 1.1 : 0.55),
        Paint()
          ..color = (index.isEven ? primary : secondary).withValues(
            alpha: 0.12 + twinkle * 0.48,
          ),
      );
    }
  }

  void _drawAmbientEnergy(
    Canvas canvas,
    Offset center,
    double radius,
    double breath,
  ) {
    _drawSoftCircle(
      canvas,
      center,
      radius * 2.42 * breath,
      [
        primary.withValues(alpha: 0.2),
        secondary.withValues(alpha: 0.07),
        Colors.transparent,
      ],
      const [0, 0.48, 1],
    );
    _drawSoftCircle(
      canvas,
      center,
      radius * 1.72 * breath,
      [
        Colors.white.withValues(alpha: 0.08),
        primary.withValues(alpha: 0.15),
        Colors.transparent,
      ],
      const [0, 0.52, 1],
    );
  }

  void _drawRadialVelocityRays(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
  ) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    for (var index = 0; index < 24; index++) {
      final angle = turn * (index.isEven ? 3 : -2) + index * math.pi / 12;
      final pulse = (math.sin(turn * 8 + index * 0.91) + 1) / 2;
      final inner = radius * (1.22 + (index % 4) * 0.08);
      final outer = inner + 9 + pulse * (12 + index % 3 * 5);
      final direction = Offset(math.cos(angle), math.sin(angle));
      paint
        ..strokeWidth = index % 6 == 0 ? 1.35 : 0.65
        ..color = (index.isEven ? primary : secondary).withValues(
          alpha: 0.08 + pulse * 0.28,
        );
      canvas.drawLine(
        center + direction * inner,
        center + direction * outer,
        paint,
      );
    }
  }

  void _drawParticleFlow(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.18);
    final tailPaint = Paint()..strokeCap = StrokeCap.round;
    final particlePaint = Paint();

    for (var index = 0; index < 58; index++) {
      final direction = index.isEven ? 1.0 : -1.0;
      final speed = 2 + index % 4;
      final angle = turn * speed * direction + index * 2.399963;
      final particleRadius = radius * (1.3 + (index % 17) * 0.071);
      final flattening = 0.36 + (index % 4) * 0.055;
      final point = Offset(
        math.cos(angle) * particleRadius,
        math.sin(angle) * particleRadius * flattening,
      );
      final tailAngle = angle - direction * (0.085 + index % 3 * 0.026);
      final tail = Offset(
        math.cos(tailAngle) * particleRadius,
        math.sin(tailAngle) * particleRadius * flattening,
      );
      final depth = (math.sin(angle) + 1) / 2;
      final color = index % 7 == 0
          ? Colors.white
          : index % 3 == 0
          ? secondary
          : primary;

      tailPaint
        ..strokeWidth = 0.9 + depth * 1.8
        ..color = color.withValues(alpha: 0.14 + depth * 0.62);
      canvas.drawLine(tail, point, tailPaint);
      particlePaint.color = color.withValues(alpha: 0.34 + depth * 0.64);
      canvas.drawCircle(point, 0.95 + depth * 2.2, particlePaint);

      if (index % 13 == 0) {
        canvas.drawCircle(
          point,
          5.5,
          Paint()
            ..color = color.withValues(alpha: 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
    canvas.restore();
  }

  void _drawOrbit(
    Canvas canvas,
    Offset center, {
    required double motion,
    required double width,
    required double height,
    required double tilt,
    required Color color,
    required Color accent,
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
        ..strokeWidth = 0.8
        ..shader = SweepGradient(
          transform: GradientRotation(motion * 0.31),
          colors: [
            Colors.transparent,
            color.withValues(alpha: alpha * 0.28),
            accent.withValues(alpha: alpha * 0.38),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.68, 1],
        ).createShader(bounds),
    );

    for (var segment = 0; segment < 5; segment++) {
      final start = motion + segment * 1.255;
      final sweep = 0.34 + segment * 0.065;
      if (segment < 2) {
        canvas.drawArc(
          bounds,
          start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = segment == 0 ? 8.5 : 5.5
            ..strokeCap = StrokeCap.round
            ..color = color.withValues(alpha: alpha * 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawArc(
        bounds,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = segment == 0 ? 4.4 : 2.2
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(
            color,
            accent,
            segment / 5,
          )!.withValues(alpha: alpha * (1 - segment * 0.11)),
      );
    }

    for (var trail = 10; trail >= 0; trail--) {
      final trailAngle = motion - trail * 0.052;
      final point = Offset(
        math.cos(trailAngle) * width / 2,
        math.sin(trailAngle) * height / 2,
      );
      final strength = 1 - trail / 11;
      canvas.drawCircle(
        point,
        nodeRadius * (0.25 + strength * 0.75),
        Paint()
          ..color = Color.lerp(
            color,
            Colors.white,
            strength * 0.45,
          )!.withValues(alpha: alpha * strength),
      );
    }
    canvas.restore();
  }

  void _drawCore(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
    double breath,
  ) {
    final core = radius * breath;
    _drawSoftCircle(
      canvas,
      center,
      core * 1.58,
      [
        primary.withValues(alpha: 0.22),
        secondary.withValues(alpha: 0.13),
        Colors.transparent,
      ],
      const [0, 0.5, 1],
    );
    _drawSoftCircle(
      canvas,
      center + Offset(-core * 0.1, -core * 0.08),
      core * 1.12,
      [
        Colors.white.withValues(alpha: 0.5),
        primary.withValues(alpha: 0.4),
        secondary.withValues(alpha: 0.2),
        Colors.transparent,
      ],
      const [0, 0.2, 0.56, 1],
      gradientCenter: const Alignment(-0.26, -0.24),
    );

    for (var lobe = 0; lobe < 5; lobe++) {
      final direction = lobe.isEven ? 1.0 : -1.0;
      final angle = turn * direction + lobe * 1.31;
      final drift = Offset(
        math.cos(angle) * core * (0.18 + lobe * 0.025),
        math.sin(angle * 1.17) * core * (0.14 + lobe * 0.018),
      );
      final color = lobe.isEven ? primary : secondary;
      _drawSoftCircle(
        canvas,
        center + drift,
        core * (0.54 + lobe * 0.045),
        [
          color.withValues(alpha: 0.38 - lobe * 0.035),
          color.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        const [0, 0.5, 1],
      );
    }

    _drawSoftCircle(
      canvas,
      center + Offset(core * 0.04, -core * 0.06),
      core * 0.5,
      [
        Colors.white.withValues(alpha: 0.48),
        primary.withValues(alpha: 0.24),
        Colors.transparent,
      ],
      const [0, 0.36, 1],
    );
  }

  void _drawCoreStreams(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var stream = 0; stream < 9; stream++) {
      final streamRadius = radius * (0.32 + stream * 0.105);
      final bounds = Rect.fromCircle(center: Offset.zero, radius: streamRadius);
      final direction = stream.isEven ? 1.0 : -1.0;
      final start =
          turn * (3 + stream % 3) * direction + stream * 0.86;
      final sweep = 0.7 + stream * 0.075;
      if (stream % 3 == 0) {
        canvas.drawArc(
          bounds,
          start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 7.5 - stream * 0.28
            ..color = primary.withValues(alpha: 0.13)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawArc(
        bounds,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.6 - stream * 0.16
          ..color = Color.lerp(
            primary,
            secondary,
            stream / 9,
          )!.withValues(alpha: 0.86 - stream * 0.055),
      );
    }
    canvas.restore();
  }

  void _drawForegroundFlares(
    Canvas canvas,
    Offset center,
    double radius,
    double turn,
  ) {
    final lineRect = Rect.fromCenter(
      center: center,
      width: radius * 3.2,
      height: 1,
    );
    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            primary.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.68),
            secondary.withValues(alpha: 0.22),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.5, 0.72, 1],
        ).createShader(lineRect),
    );

    for (var index = 0; index < 6; index++) {
      final angle =
          turn * (3 + index % 3) * (index.isEven ? 1 : -1) + index;
      final distance = radius * (1.02 + index * 0.13);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        point,
        index == 0 ? 4.2 : 2.2,
        Paint()
          ..color = (index.isEven ? Colors.white : secondary).withValues(
            alpha: 0.82,
          ),
      );
    }
  }

  void _drawSoftCircle(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colors,
    List<double> stops, {
    Alignment gradientCenter = Alignment.center,
  }) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: gradientCenter,
          colors: colors,
          stops: stops,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _HyperSyncPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}

class _VelocityIndicatorPainter extends CustomPainter {
  _VelocityIndicatorPainter({
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
    final centerY = size.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, centerY - 1, size.width, 2),
        const Radius.circular(99),
      ),
      Paint()..color = const Color(0x262E405D),
    );

    for (var streak = 0; streak < 3; streak++) {
      final progress = (phase * 5 + streak * 0.34) % 1;
      final x = progress * size.width;
      final length = 22.0 + streak * 9;
      final rect = Rect.fromLTWH(x - length, centerY - 1.25, length, 2.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(99)),
        Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.transparent,
              (streak.isEven ? primary : secondary).withValues(alpha: 0.9),
              Colors.white,
            ],
          ).createShader(rect),
      );
    }

    for (var index = 0; index < 7; index++) {
      final wave =
          (math.sin((phase * 5 - index * 0.16) * math.pi * 2) + 1) / 2;
      final x = size.width / 2 - 27 + index * 9;
      canvas.drawCircle(
        Offset(x, centerY),
        1 + wave * 1.15,
        Paint()
          ..color = (index.isEven ? primary : secondary).withValues(
            alpha: 0.2 + wave * 0.8,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VelocityIndicatorPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}
