import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/visual_mode.dart';
import '../theme/app_theme.dart';

/// Animated first-sync state that follows the dashboard's neon glass style.
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
      label: '正在同步账户额度，请稍候',
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final phase = _controller.value;
            return Container(
              key: Key(energyMode ? 'energy-sync-orb' : 'console-sync-orb'),
              height: 430,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xDC141E31), Color(0xE6090E19)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: primary.withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: 32,
                    spreadRadius: -8,
                  ),
                  const BoxShadow(
                    color: Color(0x8A000000),
                    blurRadius: 28,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SyncOrbPainter(
                        phase: phase,
                        primary: primary,
                        secondary: secondary,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    child: _SyncBadge(primary: primary, phase: phase),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 27,
                    child: Column(
                      children: [
                        Text(
                          '正在同步账户额度',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: primary.withValues(alpha: 0.45),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '建立安全连接  ·  读取账户状态',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0xFF8391AA),
                                fontSize: 11,
                                letterSpacing: 0.7,
                              ),
                        ),
                        const SizedBox(height: 13),
                        _SignalDots(
                          phase: phase,
                          primary: primary,
                          secondary: secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  const _SyncBadge({required this.primary, required this.phase});

  final Color primary;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final pulse = (math.sin(phase * math.pi * 4) + 1) / 2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x6E101827),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.5 + pulse * 0.35),
                  blurRadius: 5 + pulse * 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'INITIAL SYNC',
            style: TextStyle(
              color: primary.withValues(alpha: 0.9),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalDots extends StatelessWidget {
  const _SignalDots({
    required this.phase,
    required this.primary,
    required this.secondary,
  });

  final double phase;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 3; index++) ...[
          if (index > 0) const SizedBox(width: 7),
          Builder(
            builder: (context) {
              final wave =
                  (math.sin((phase * 3 - index * 0.22) * math.pi * 2) + 1) / 2;
              final color = index == 1 ? secondary : primary;
              return Transform.scale(
                scale: 0.72 + wave * 0.38,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.35 + wave * 0.65),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: wave * 0.65),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SyncOrbPainter extends CustomPainter {
  const _SyncOrbPainter({
    required this.phase,
    required this.primary,
    required this.secondary,
  });

  final double phase;
  final Color primary;
  final Color secondary;

  static const _stars = <Offset>[
    Offset(0.08, 0.22),
    Offset(0.15, 0.47),
    Offset(0.22, 0.31),
    Offset(0.29, 0.16),
    Offset(0.35, 0.56),
    Offset(0.43, 0.25),
    Offset(0.56, 0.14),
    Offset(0.63, 0.55),
    Offset(0.72, 0.25),
    Offset(0.81, 0.43),
    Offset(0.88, 0.19),
    Offset(0.92, 0.54),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, 205);
    final shortestSide = math.min(size.width, size.height);
    final scale = (shortestSide / 430).clamp(0.74, 1.0);
    final pulse = (math.sin(phase * math.pi * 2) + 1) / 2;

    final ambientRect = Rect.fromCircle(center: center, radius: 165 * scale);
    canvas.drawCircle(
      center,
      165 * scale,
      Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withValues(alpha: 0.13 + pulse * 0.04),
            secondary.withValues(alpha: 0.045),
            Colors.transparent,
          ],
          stops: const [0, 0.5, 1],
        ).createShader(ambientRect),
    );

    for (var index = 0; index < _stars.length; index++) {
      final star = _stars[index];
      final twinkle =
          (math.sin((phase * 2 + index * 0.19) * math.pi * 2) + 1) / 2;
      final position = Offset(star.dx * size.width, star.dy * size.height);
      canvas.drawCircle(
        position,
        0.6 + twinkle * 0.9,
        Paint()
          ..color = (index.isEven ? primary : secondary).withValues(
            alpha: 0.12 + twinkle * 0.38,
          ),
      );
    }

    _drawOrbit(
      canvas,
      center,
      width: 238 * scale,
      height: 100 * scale,
      rotation: -0.22,
      progress: phase,
      color: primary,
      particleRadius: 3.1 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      width: 194 * scale,
      height: 142 * scale,
      rotation: 0.62,
      progress: 1 - phase * 0.72,
      color: secondary,
      particleRadius: 2.5 * scale,
    );
    _drawOrbit(
      canvas,
      center,
      width: 148 * scale,
      height: 176 * scale,
      rotation: -0.5,
      progress: phase * 0.56 + 0.32,
      color: primary,
      particleRadius: 1.8 * scale,
    );

    final coreRadius = (48 + pulse * 4) * scale;
    canvas.drawCircle(
      center,
      coreRadius * 1.25,
      Paint()
        ..color = primary.withValues(alpha: 0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );
    final coreRect = Rect.fromCircle(center: center, radius: coreRadius);
    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.32),
          colors: [
            Colors.white.withValues(alpha: 0.96),
            primary.withValues(alpha: 0.9),
            secondary.withValues(alpha: 0.46),
            primary.withValues(alpha: 0.04),
          ],
          stops: const [0, 0.17, 0.58, 1],
        ).createShader(coreRect),
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2 * scale
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          Colors.transparent,
          primary.withValues(alpha: 0.95),
          secondary.withValues(alpha: 0.72),
          Colors.transparent,
        ],
        stops: const [0, 0.35, 0.68, 1],
        transform: GradientRotation(phase * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: 68 * scale));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 68 * scale),
      -math.pi * 0.72,
      math.pi * 1.52,
      false,
      ringPaint,
    );

    final flareAngle = phase * math.pi * 2;
    final flare =
        center +
        Offset(math.cos(flareAngle), math.sin(flareAngle)) * 68 * scale;
    canvas.drawCircle(
      flare,
      2.2 * scale,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _drawOrbit(
    Canvas canvas,
    Offset center, {
    required double width,
    required double height,
    required double rotation,
    required double progress,
    required Color color,
    required double particleRadius,
  }) {
    final orbit = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawOval(
      orbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..color = color.withValues(alpha: 0.18),
    );

    final angle = progress * math.pi * 2;
    final particle = Offset(
      math.cos(angle) * width / 2,
      math.sin(angle) * height / 2,
    );
    canvas.drawCircle(
      particle,
      particleRadius * 3,
      Paint()
        ..color = color.withValues(alpha: 0.26)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(particle, particleRadius, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SyncOrbPainter oldDelegate) {
    return phase != oldDelegate.phase ||
        primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary;
  }
}
