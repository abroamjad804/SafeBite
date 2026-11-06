import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import 'fx.dart';

// ─────────────────────────── Logo ───────────────────────────

/// "SafeBite" wordmark: the S sits inside a leafy ring.
class SafeBiteLogo extends StatelessWidget {
  final double fontSize;
  final bool tagline;
  const SafeBiteLogo({super.key, this.fontSize = 40, this.tagline = true});

  @override
  Widget build(BuildContext context) {
    final ring = fontSize * 1.3;
    final style = GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: AppColors.primaryDark,
      height: 1.0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: ring,
              height: ring,
              child: CustomPaint(
                painter: _LogoMarkPainter(),
                child: Center(child: Text('S', style: style)),
              ),
            ),
            Transform.translate(
              offset: Offset(-fontSize * 0.1, 0),
              child: Text('afeBite', style: style),
            ),
          ],
        ),
        if (tagline) ...[
          SizedBox(height: fontSize * 0.2),
          Text(
            'Eat smart. Live well.',
            style: GoogleFonts.nunito(
              fontSize: fontSize * 0.36,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final stroke = size.shortestSide * 0.085;
    final r = size.shortestSide / 2 - stroke;
    final rect = Rect.fromCircle(center: c, radius: r);
    // Open ring: gap at the top-right where the leaves sprout.
    canvas.drawArc(
      rect,
      -math.pi * 0.1,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primaryDark,
    );
    final base = c + Offset(r * 0.62, -r * 0.78);
    paintLeaf(canvas, base, size.shortestSide * 0.42, -math.pi * 0.42, AppColors.mint);
    paintLeaf(canvas, base, size.shortestSide * 0.3, -math.pi * 0.05, AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────── Barcode ───────────────────────────

class BarcodePainter extends CustomPainter {
  final Color color;
  const BarcodePainter({this.color = AppColors.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(5);
    final unit = size.width / 80;
    final p = Paint()..color = color;
    double x = 0;
    while (x < size.width) {
      final bar = (1 + rnd.nextInt(3)) * unit;
      canvas.drawRect(Rect.fromLTWH(x, 0, math.min(bar, size.width - x), size.height), p);
      x += bar + (1 + rnd.nextInt(2)) * unit;
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter old) => old.color != color;
}

// ─────────────────────────── Salad bowl (splash) ───────────────────────────

class SaladBowl extends StatelessWidget {
  final double width;
  const SaladBowl({super.key, this.width = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.62,
      child: CustomPaint(painter: _SaladPainter()),
    );
  }
}

class _SaladPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rnd = math.Random(11);

    const veg = <Color>[
      Color(0xFFE5484D), // tomato
      Color(0xFFF5B82E), // yellow pepper
      Color(0xFFF28C28), // carrot
      Color(0xFF8E5BA8), // cabbage
      Color(0xFFA8D08D), // cucumber
    ];
    const greens = <Color>[Color(0xFF6DB33F), Color(0xFF3F8F25), Color(0xFF8CCB52)];

    // Back layer of leafy greens.
    for (int i = 0; i < 14; i++) {
      final x = w * (0.14 + rnd.nextDouble() * 0.72);
      final dx = (x - w / 2).abs() / (w * 0.4);
      final y = h * 0.34 + dx * dx * h * 0.16 + rnd.nextDouble() * h * 0.1;
      paintLeaf(canvas, Offset(x, y), w * (0.13 + rnd.nextDouble() * 0.07),
          -math.pi * (0.1 + rnd.nextDouble() * 0.8), greens[i % greens.length]);
    }

    // Vegetables.
    for (int i = 0; i < 26; i++) {
      final x = w * (0.16 + rnd.nextDouble() * 0.68);
      final dx = (x - w / 2).abs() / (w * 0.36);
      final y = h * 0.3 + dx * dx * h * 0.16 + rnd.nextDouble() * h * 0.2;
      final r = w * (0.04 + rnd.nextDouble() * 0.03);
      final base = veg[i % veg.length];
      final c = Offset(x, y);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            colors: [Color.lerp(base, Colors.white, 0.35)!, base],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
      canvas.drawCircle(c + Offset(-r * 0.3, -r * 0.35), r * 0.18,
          Paint()..color = Colors.white.withValues(alpha: 0.6));
    }

    // Front greens overlapping the rim.
    for (int i = 0; i < 8; i++) {
      final x = w * (0.2 + rnd.nextDouble() * 0.6);
      paintLeaf(canvas, Offset(x, h * 0.5), w * 0.12,
          -math.pi * (0.2 + rnd.nextDouble() * 0.6), greens[(i + 1) % greens.length]);
    }

    // Bowl.
    final bowl = Path()
      ..moveTo(w * 0.05, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.95, h * 0.5)
      ..cubicTo(w * 0.93, h * 0.86, w * 0.72, h * 0.99, w * 0.5, h * 0.99)
      ..cubicTo(w * 0.28, h * 0.99, w * 0.07, h * 0.86, w * 0.05, h * 0.5)
      ..close();
    canvas.drawShadow(bowl, const Color(0x552F7A1C), 10, false);
    canvas.drawPath(
      bowl,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFE9F1E3)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.05, h * 0.5)
        ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.95, h * 0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFD7E5CC),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────── Onboarding illustrations ───────────────────────────

/// Phone scanning a food pouch.
class ScanPhoneIllustration extends StatelessWidget {
  const ScanPhoneIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFFFFE9A8).withValues(alpha: 0.9),
                const Color(0xFFFFE9A8).withValues(alpha: 0),
              ]),
            ),
          ),
          // Food pouch
          Positioned(
            right: 14,
            top: 26,
            child: Transform.rotate(
              angle: 0.18,
              child: Container(
                width: 92,
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.mint, AppColors.primaryDark],
                  ),
                  boxShadow: Fx.glow(AppColors.primaryDark, alpha: 0.3),
                ),
                child: const Center(
                  child: Icon(Icons.eco_rounded, color: Colors.white, size: 44),
                ),
              ),
            ),
          ),
          // Phone
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 122,
              height: 210,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(28),
                boxShadow: Fx.glow(AppColors.deepGreen, alpha: 0.35, blur: 24, dy: 12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Container(
                    width: 84,
                    height: 62,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const CustomPaint(painter: BarcodePainter()),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
              top: 8, left: 40, child: Icon(Icons.auto_awesome, color: Color(0xFFF5B82E), size: 20)),
          Positioned(top: 150, right: 6, child: Leaf(size: 40, angle: -0.8, color: AppColors.mint)),
        ],
      ),
    );
  }
}

/// Soft glow, white tile and a big icon, with leaves — for pages without a custom scene.
class FeatureIllustration extends StatelessWidget {
  final IconData icon;
  final IconData badge;
  final Color color;
  const FeatureIllustration({
    super.key,
    required this.icon,
    required this.badge,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                color.withValues(alpha: 0.28),
                color.withValues(alpha: 0),
              ]),
            ),
          ),
          Transform.rotate(
            angle: -0.08,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(48),
                boxShadow: Fx.glow(color, alpha: 0.25, blur: 30, dy: 16),
              ),
              child: Icon(icon, size: 92, color: color),
            ),
          ),
          Positioned(
            top: 18,
            right: 22,
            child: IconBadge(icon: badge, color: color, size: 52),
          ),
          Positioned(bottom: 26, left: 10, child: Leaf(size: 56, angle: -0.5, color: AppColors.mint)),
          Positioned(bottom: 40, right: 8, child: Leaf(size: 36, angle: 0.4, color: AppColors.primary.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
