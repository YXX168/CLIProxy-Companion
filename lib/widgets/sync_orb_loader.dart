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
    final center = Offset(size.width / 2, size.height * 0.6);
    final radius = size.shortestSide * 0.47;
    final progress = animation.value;
    final phase = progress * math.pi * 2;
    final pulse = (math.sin(phase) + 1) / 2;

    canvas.drawCircle(
      center,
      radius * (0.94 + pulse * 0.035),
      Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.27),
            primary.withValues(alpha: 0.12),
            primary.withValues(alpha: 0.035),
            Colors.transparent,
          ],
          stops: const [0, 0.28, 0.67, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius * 0.48,
      Paint()
        ..color = primary.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    for (var index = 0; index < 2; index++) {
      final wave = (progress + index * 0.5) % 1;
      canvas.drawCircle(
        center,
        radius * (0.5 + wave * 0.43),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = primary.withValues(alpha: (1 - wave) * 0.2),
      );
    }

    for (var index = 0; index < 12; index++) {
      final angle = phase * 0.12 + index * math.pi / 6;
      final rayPulse = (math.sin(phase * 1.4 + index * 1.7) + 1) / 2;
      final inner = radius * 0.48;
      final outer = radius * (0.62 + rayPulse * 0.13);
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * inner,
          center.dy + math.sin(angle) * inner,
        ),
        Offset(
          center.dx + math.cos(angle) * outer,
          center.dy + math.sin(angle) * outer,
        ),
        Paint()
          ..strokeWidth = index.isEven ? 0.7 : 0.45
          ..strokeCap = StrokeCap.round
          ..color = primary.withValues(alpha: 0.055 + rayPulse * 0.055),
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(phase * 0.24 - 0.3);
    final wideOrbit = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.82,
      height: radius * 0.9,
    );
    canvas.drawOval(
      wideOrbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..color = primary.withValues(alpha: 0.23),
    );
    canvas.drawArc(
      wideOrbit,
      phase * 0.55,
      math.pi * 0.58,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-phase * 0.18 + 0.88);
    final tallOrbit = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.18,
      height: radius * 1.78,
    );
    canvas.drawOval(
      tallOrbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.55
        ..color = secondary.withValues(alpha: 0.16),
    );
    canvas.drawArc(
      tallOrbit,
      -phase * 0.42,
      math.pi * 0.42,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..color = primary.withValues(alpha: 0.55),
    );
    canvas.restore();

    for (var index = 0; index < 6; index++) {
      final speed = 0.38 + (index % 3) * 0.11;
      final angle = phase * speed + index * math.pi * 2 / 6;
      final orbitX = radius * (0.61 + (index % 2) * 0.17);
      final orbitY = radius * (0.43 + (index % 3) * 0.08);
      final particle = Offset(
        center.dx + math.cos(angle) * orbitX,
        center.dy + math.sin(angle) * orbitY,
      );
      final particleSize = index == 0 ? 2.1 : 1.15 + (index % 2) * 0.35;
      if (index == 0 || index == 3) {
        canvas.drawCircle(
          particle,
          particleSize * 2.6,
          Paint()
            ..color = primary.withValues(alpha: index == 0 ? 0.24 : 0.1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
      canvas.drawCircle(
        particle,
        particleSize,
        Paint()
          ..color = index == 0
              ? Colors.white.withValues(alpha: 0.95)
              : primary.withValues(alpha: 0.8),
      );
      if (index == 0) {
        final flarePaint = Paint()
          ..strokeWidth = 0.7
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.46);
        canvas.drawLine(
          particle.translate(-4, 0),
          particle.translate(4, 0),
          flarePaint,
        );
        canvas.drawLine(
          particle.translate(0, -4),
          particle.translate(0, 4),
          flarePaint,
        );
      }
    }

    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.6);
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = primary.withValues(alpha: 0.13),
    );
    canvas.drawArc(
      ringRect,
      phase * 0.34 - math.pi / 2,
      math.pi * 1.45,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.75
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          transform: GradientRotation(phase * 0.34),
          colors: [
            primary.withValues(alpha: 0.16),
            primary.withValues(alpha: 0.94),
            secondary.withValues(alpha: 0.82),
            Colors.white.withValues(alpha: 0.76),
            primary.withValues(alpha: 0.16),
          ],
        ).createShader(ringRect),
    );

    canvas.drawCircle(
      center,
      radius * (0.31 + pulse * 0.018),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.34),
          colors: [
            Colors.white.withValues(alpha: 0.52),
            primary.withValues(alpha: 0.86),
            primary.withValues(alpha: 0.32),
            Colors.transparent,
          ],
          stops: const [0, 0.26, 0.72, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.34)),
    );
    canvas.drawCircle(
      center,
      radius * 0.33,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..shader = SweepGradient(
          transform: GradientRotation(-phase * 0.2),
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.52),
            primary.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.08),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.34)),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.25),
      -phase * 0.7 - math.pi * 0.15,
      math.pi * 0.72,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.48),
    );
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
