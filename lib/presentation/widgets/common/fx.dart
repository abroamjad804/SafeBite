import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Shared visual building blocks used across the whole app.
class Fx {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A2F7A1C), blurRadius: 22, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A1F5E14), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static List<BoxShadow> glow(Color c,
          {double alpha = 0.35, double blur = 20, double dy = 8}) =>
      [BoxShadow(color: c.withValues(alpha: alpha), blurRadius: blur, offset: Offset(0, dy))];
}

// ─────────────────────────── Leaf decoration ───────────────────────────

Path _leafPath(double w, double h) => Path()
  ..moveTo(0, h / 2)
  ..quadraticBezierTo(w * 0.35, -h * 0.35, w, h / 2)
  ..quadraticBezierTo(w * 0.35, h * 1.35, 0, h / 2)
  ..close();

/// Draws a leaf whose stem sits at [base], pointing along [angle] (radians).
void paintLeaf(
    Canvas canvas, Offset base, double length, double angle, Color color) {
  final h = length * 0.5;
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angle);
  canvas.translate(0, -h / 2);
  canvas.drawPath(_leafPath(length, h), Paint()..color = color);
  canvas.drawLine(
    Offset(0, h / 2),
    Offset(length * 0.92, h / 2),
    Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = math.max(1.0, length * 0.025)
      ..strokeCap = StrokeCap.round,
  );
  canvas.restore();
}

class _LeafPainter extends CustomPainter {
  final Color color;
  const _LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) =>
      paintLeaf(canvas, Offset(0, size.height / 2), size.width, 0, color);

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.color != color;
}

class Leaf extends StatelessWidget {
  final double size;
  final Color color;
  final double angle;
  const Leaf({
    super.key,
    this.size = 40,
    this.color = AppColors.mint,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Transform.rotate(
          angle: angle,
          child: CustomPaint(
            size: Size(size, size * 0.5),
            painter: _LeafPainter(color),
          ),
        ),
      );
}

/// Pale mint gradient with soft leaves in the corners.
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool leaves;
  const AppBackground({super.key, required this.child, this.leaves = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, Color(0xFFE8F4DD)],
        ),
      ),
      child: Stack(
        children: [
          if (leaves) ...[
            Positioned(
                top: 6,
                right: -14,
                child: Leaf(
                    size: 104,
                    angle: 2.35,
                    color: AppColors.mint.withValues(alpha: 0.32))),
            Positioned(
                top: 58,
                right: 18,
                child: Leaf(
                    size: 56,
                    angle: 1.85,
                    color: AppColors.primary.withValues(alpha: 0.18))),
            Positioned(
                bottom: 110,
                left: -30,
                child: Leaf(
                    size: 120,
                    angle: -0.55,
                    color: AppColors.mint.withValues(alpha: 0.26))),
            Positioned(
                bottom: 70,
                left: 34,
                child: Leaf(
                    size: 60,
                    angle: -1.05,
                    color: AppColors.primary.withValues(alpha: 0.14))),
          ],
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────── Headers & titles ───────────────────────────

class PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? action;
  const PageHeader({super.key, required this.title, this.onBack, this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: onBack != null
                  ? IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.ink),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink),
              ),
            ),
            SizedBox(width: 46, child: action),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// "View All →" style text link.
class LinkText extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const LinkText(this.label, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          const SizedBox(width: 3),
          const Icon(Icons.arrow_forward_rounded,
              size: 15, color: AppColors.primaryDark),
        ],
      ),
    );
  }
}

// ─────────────────────────── Cards & badges ───────────────────────────

/// Soft tinted circle (or squircle) holding a line icon.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool circle;
  const IconBadge({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.size = 44,
    this.circle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class RaisedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const RaisedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.color,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: br,
        boxShadow: Fx.card,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Primary green button with a trailing arrow (or any trailing icon).
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final List<Color> colors;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
    this.colors = const [Color(0xFF5FAE38), Color(0xFF3A8721)],
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: () => setState(() => _down = false),
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Opacity(
          opacity: widget.onPressed == null && !widget.loading ? 0.5 : 1,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.colors,
              ),
              boxShadow: Fx.glow(widget.colors.last, alpha: 0.35, blur: 16, dy: 8),
            ),
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 8),
                          Icon(widget.icon, color: Colors.white, size: 20),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Status ───────────────────────────

class StatusStyle {
  final Color color;
  final IconData icon;
  final String text;
  const StatusStyle(this.color, this.icon, this.text);

  static StatusStyle of(String label) {
    switch (label.toLowerCase()) {
      case 'safe':
        return const StatusStyle(AppColors.safe, Icons.check_circle_rounded, 'Safe');
      case 'caution':
        return const StatusStyle(AppColors.caution, Icons.error_rounded, 'Caution');
      case 'avoid':
        return const StatusStyle(AppColors.avoid, Icons.cancel_rounded, 'Avoid');
      default:
        return const StatusStyle(AppColors.unverified, Icons.help_rounded, 'Unverified');
    }
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  const StatusPill(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = StatusStyle.of(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 14, color: s.color),
          const SizedBox(width: 4),
          Text(s.text,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: s.color)),
        ],
      ),
    );
  }
}

/// Large filled status pill (check icon + label), used on result screens.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  final bool large;
  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 26 : 16, vertical: large ? 11 : 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: Fx.glow(color, alpha: 0.35, blur: 14, dy: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: large ? 26 : 20),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: large ? 24 : 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

/// Small rounded chip: tinted background, optional icon.
class InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const InfoChip({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

/// Picks a sensible icon tile for a product from its name.
class ProductThumb extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  const ProductThumb({super.key, required this.name, this.size = 46, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final n = name.toLowerCase();
    IconData icon = Icons.shopping_basket_rounded;
    Color color = AppColors.primary;
    if (n.contains('juice') || n.contains('cola') || n.contains('drink') || n.contains('water')) {
      icon = Icons.local_drink_rounded;
      color = const Color(0xFFFF8A3D);
    } else if (n.contains('chip') || n.contains('pringles')) {
      icon = Icons.fastfood_rounded;
      color = const Color(0xFFF2B01E);
    } else if (n.contains('oreo') || n.contains('cookie') || n.contains('biscuit')) {
      icon = Icons.bakery_dining_rounded;
      color = const Color(0xFF8D6E63);
    } else if (n.contains('nutella') || n.contains('choco') || n.contains('kit')) {
      icon = Icons.icecream_rounded;
      color = const Color(0xFFB4533A);
    } else if (n.contains('corn') || n.contains('cereal')) {
      icon = Icons.breakfast_dining_rounded;
      color = AppColors.primary;
    } else if (n.contains('ketchup') || n.contains('sauce')) {
      icon = Icons.restaurant_rounded;
      color = const Color(0xFFE5484D);
    }
    final fallback = IconBadge(icon: icon, color: color, size: size, circle: false);
    if (imageUrl == null) return fallback;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.divider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.3),
        child: Image.network(imageUrl!,
            fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}

// ─────────────────────────── Score ring ───────────────────────────

class ScoreRing extends StatelessWidget {
  final double value; // 0..100
  final Color color;
  final Color? trackColor;
  final double size;
  final double stroke;
  final Widget? child;
  const ScoreRing({
    super.key,
    required this.value,
    required this.color,
    this.trackColor,
    this.size = 150,
    this.stroke = 12,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: (value / 100).clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, color, trackColor ?? color.withValues(alpha: 0.14), stroke),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter(this.v, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = track,
    );
    if (v <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * v,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          colors: [color.withValues(alpha: 0.6), color],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.v != v || old.color != color || old.track != track;
}

// ─────────────────────────── Loading dots ───────────────────────────

class PulseDots extends StatefulWidget {
  const PulseDots({super.key});

  @override
  State<PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<PulseDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final active = (_c.value * 3).floor().clamp(0, 2);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final on = i == active;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: on ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: on
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
