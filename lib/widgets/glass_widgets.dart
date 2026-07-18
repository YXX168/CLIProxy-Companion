import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            top: -128,
            right: -118,
            child: _GlowOrb(size: 336, color: AppTheme.violet),
          ),
          const Positioned(
            top: 210,
            left: -220,
            child: _GlowOrb(size: 390, color: AppTheme.magenta),
          ),
          const Positioned(
            bottom: -170,
            right: -130,
            child: _GlowOrb(size: 390, color: AppTheme.cyan),
          ),
          const Positioned.fill(
            child: CustomPaint(painter: _AtmospherePainter()),
          ),
          child,
        ],
      ),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x0D7DCBFF)
      ..strokeWidth = 0.55;
    const gridSize = 44.0;
    for (var x = -gridSize; x < size.width + gridSize; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = -gridSize; y < size.height + gridSize; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final beamPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x0055DDF4), Color(0x1855DDF4), Color(0x009678FF)],
        stops: [0, 0.48, 1],
      ).createShader(Offset.zero & size);
    final beam = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.34, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(beam, beamPaint);

    final particlePaint = Paint()..color = const Color(0x407FDFF3);
    for (var index = 0; index < 18; index++) {
      final x = ((index * 83 + 31) % 997) / 997 * size.width;
      final y = ((index * 137 + 59) % 991) / 991 * size.height;
      canvas.drawCircle(
        Offset(x, y),
        index % 4 == 0 ? 1.2 : 0.7,
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor ?? const Color(0xFF2A3952),
          width: 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x52000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x122C9DD6),
            blurRadius: 18,
            offset: Offset(-4, -3),
          ),
        ],
      ),
      child: child,
    );

    return Container(
      margin: margin,
      child: onTap == null
          ? content
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: content,
              ),
            ),
    );
  }
}

class GradientIcon extends StatelessWidget {
  const GradientIcon({
    required this.icon,
    super.key,
    this.size = 48,
    this.iconSize = 24,
  });

  final IconData icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          colors: [AppTheme.cyan, AppTheme.violet, AppTheme.magenta],
          stops: [0, 0.58, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5538E8FF),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
          BoxShadow(color: Color(0x269678FF), blurRadius: 26),
        ],
        border: Border.all(color: const Color(0x66D9F8FF), width: 0.7),
      ),
      child: Icon(icon, color: AppTheme.background, size: iconSize),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.color,
    super.key,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? Icons.circle, size: 10, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
