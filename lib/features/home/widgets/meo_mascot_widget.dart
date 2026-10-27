import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/cat_state.dart';
import '../../../core/constants/app_colors.dart';

class MeoMascotWidget extends StatefulWidget {
  final CatMood mood;
  final String breed; // 'orange', 'tabby', 'calico', 'black', 'white'
  final List<String> equippedAccessories;
  final double size;
  final VoidCallback? onTap;

  const MeoMascotWidget({
    super.key,
    this.mood = CatMood.happy,
    this.breed = 'orange',
    this.equippedAccessories = const [],
    this.size = 180.0,
    this.onTap,
  });

  @override
  State<MeoMascotWidget> createState() => _MeoMascotWidgetState();
}

class _MeoMascotWidgetState extends State<MeoMascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _wagAnimation;
  late Animation<double> _breatheAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _wagAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _breatheAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _catBodyColor {
    switch (widget.breed) {
      case 'orange':
        return const Color(0xFFFFB26B);
      case 'tabby':
        return const Color(0xFFC7A788);
      case 'calico':
        return const Color(0xFFF0D5BA);
      case 'black':
        return const Color(0xFF4A4440);
      case 'white':
        return const Color(0xFFFAF7F2);
      default:
        return const Color(0xFFFFB26B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isDancing = widget.mood == CatMood.dancing;
          final danceOffset = isDancing ? math.sin(_controller.value * math.pi * 4) * 8.0 : 0.0;

          return Transform.translate(
            offset: Offset(0, danceOffset),
            child: Transform.scale(
              scale: _breatheAnimation.value,
              child: CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CatPainter(
                  mood: widget.mood,
                  bodyColor: _catBodyColor,
                  wagAngle: _wagAnimation.value,
                  breed: widget.breed,
                  accessories: widget.equippedAccessories,
                  animProgress: _controller.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final CatMood mood;
  final Color bodyColor;
  final double wagAngle;
  final String breed;
  final List<String> accessories;
  final double animProgress;

  _CatPainter({
    required this.mood,
    required this.bodyColor,
    required this.wagAngle,
    required this.breed,
    required this.accessories,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;

    // 1. Shadow underneath
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.95),
        width: radius * 1.8,
        height: radius * 0.35,
      ),
      shadowPaint,
    );

    // 2. Tail
    _drawTail(canvas, center, radius);

    // 3. Ears
    _drawEars(canvas, center, radius);

    // 4. Cat Body / Head (Round chubby silhouette)
    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawCircle(center, radius, bodyPaint);

    // Subtle dark border
    final outlinePaint = Paint()
      ..color = const Color(0xFF4A3728).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, outlinePaint);

    // Breed patterns (stripes for tabby/orange)
    if (breed == 'tabby' || breed == 'orange') {
      _drawStripes(canvas, center, radius);
    }

    // 5. Rosy Cheeks (Má hồng)
    final blushPaint = Paint()..color = const Color(0xFFFF9494).withOpacity(0.5);
    canvas.drawCircle(Offset(center.dx - radius * 0.52, center.dy + radius * 0.18), radius * 0.15, blushPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.52, center.dy + radius * 0.18), radius * 0.15, blushPaint);

    // 6. Eyes & Eyebrows based on mood
    _drawEyes(canvas, center, radius);

    // 7. Cute Nose & Whiskers
    _drawNoseAndWhiskers(canvas, center, radius);

    // 8. Paws
    _drawPaws(canvas, center, radius);

    // 9. Collar with Golden Money Pouch / Bell
    _drawCollarAndPouch(canvas, center, radius);

    // 10. Accessories
    if (accessories.contains('glasses')) {
      _drawGlasses(canvas, center, radius);
    }
    if (accessories.contains('bow_tie')) {
      _drawBowTie(canvas, center, radius);
    }
  }

  void _drawTail(Canvas canvas, Offset center, double radius) {
    final tailPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = radius * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final start = Offset(center.dx + radius * 0.75, center.dy + radius * 0.5);
    final end = Offset(
      center.dx + radius * 1.25 + math.sin(wagAngle) * 15,
      center.dy - radius * 0.1 + math.cos(wagAngle) * 10,
    );

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(center.dx + radius * 1.1, center.dy + radius * 0.3, end.dx, end.dy);
    canvas.drawPath(path, tailPaint);
  }

  void _drawEars(Canvas canvas, Offset center, double radius) {
    final earPaint = Paint()..color = bodyColor;
    final earInnerPaint = Paint()..color = const Color(0xFFFFC0BD);

    // Left ear
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.8, center.dy - radius * 0.3)
      ..lineTo(center.dx - radius * 0.65, center.dy - radius * 1.05)
      ..lineTo(center.dx - radius * 0.15, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(leftEarPath, earPaint);

    final leftInner = Path()
      ..moveTo(center.dx - radius * 0.72, center.dy - radius * 0.35)
      ..lineTo(center.dx - radius * 0.62, center.dy - radius * 0.95)
      ..lineTo(center.dx - radius * 0.25, center.dy - radius * 0.75)
      ..close();
    canvas.drawPath(leftInner, earInnerPaint);

    // Right ear
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.8, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.65, center.dy - radius * 1.05)
      ..lineTo(center.dx + radius * 0.15, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(rightEarPath, earPaint);

    final rightInner = Path()
      ..moveTo(center.dx + radius * 0.72, center.dy - radius * 0.35)
      ..lineTo(center.dx + radius * 0.62, center.dy - radius * 0.95)
      ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.75)
      ..close();
    canvas.drawPath(rightInner, earInnerPaint);
  }

  void _drawStripes(Canvas canvas, Offset center, double radius) {
    final stripePaint = Paint()
      ..color = const Color(0xFFE58D43).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Forehead stripes
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.85),
      Offset(center.dx, center.dy - radius * 0.6),
      stripePaint,
    );
    canvas.drawLine(
      Offset(center.dx - 12, center.dy - radius * 0.8),
      Offset(center.dx - 8, center.dy - radius * 0.6),
      stripePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 12, center.dy - radius * 0.8),
      Offset(center.dx + 8, center.dy - radius * 0.6),
      stripePaint,
    );
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final eyePaint = Paint()..color = const Color(0xFF2C221E);
    final eyeWhite = Paint()..color = Colors.white;

    final leftEyeCenter = Offset(center.dx - radius * 0.36, center.dy - radius * 0.05);
    final rightEyeCenter = Offset(center.dx + radius * 0.36, center.dy - radius * 0.05);

    if (mood == CatMood.sleeping) {
      // Sleeping curved lines ^_^
      final sleepPaint = Paint()
        ..color = const Color(0xFF2C221E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final pLeft = Path()
        ..moveTo(leftEyeCenter.dx - 10, leftEyeCenter.dy)
        ..quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy - 8, leftEyeCenter.dx + 10, leftEyeCenter.dy);
      final pRight = Path()
        ..moveTo(rightEyeCenter.dx - 10, rightEyeCenter.dy)
        ..quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy - 8, rightEyeCenter.dx + 10, rightEyeCenter.dy);

      canvas.drawPath(pLeft, sleepPaint);
      canvas.drawPath(pRight, sleepPaint);
    } else if (mood == CatMood.happy || mood == CatMood.dancing) {
      // Happy inverted U eyes ^^
      final happyPaint = Paint()
        ..color = const Color(0xFF2C221E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final pLeft = Path()
        ..moveTo(leftEyeCenter.dx - 11, leftEyeCenter.dy + 2)
        ..quadraticBezierTo(leftEyeCenter.dx, leftEyeCenter.dy - 10, leftEyeCenter.dx + 11, leftEyeCenter.dy + 2);
      final pRight = Path()
        ..moveTo(rightEyeCenter.dx - 11, rightEyeCenter.dy + 2)
        ..quadraticBezierTo(rightEyeCenter.dx, rightEyeCenter.dy - 10, rightEyeCenter.dx + 11, rightEyeCenter.dy + 2);

      canvas.drawPath(pLeft, happyPaint);
      canvas.drawPath(pRight, happyPaint);
    } else {
      // Big sparkling round eyes
      final eyeRadius = radius * 0.15;
      canvas.drawCircle(leftEyeCenter, eyeRadius, eyePaint);
      canvas.drawCircle(rightEyeCenter, eyeRadius, eyePaint);

      // Light reflection
      canvas.drawCircle(Offset(leftEyeCenter.dx - 3, leftEyeCenter.dy - 3), eyeRadius * 0.35, eyeWhite);
      canvas.drawCircle(Offset(rightEyeCenter.dx - 3, rightEyeCenter.dy - 3), eyeRadius * 0.35, eyeWhite);

      if (mood == CatMood.excited) {
        // Extra star twinkle in eyes
        canvas.drawCircle(Offset(leftEyeCenter.dx + 4, leftEyeCenter.dy + 3), eyeRadius * 0.2, eyeWhite);
        canvas.drawCircle(Offset(rightEyeCenter.dx + 4, rightEyeCenter.dy + 3), eyeRadius * 0.2, eyeWhite);
      }
    }
  }

  void _drawNoseAndWhiskers(Canvas canvas, Offset center, double radius) {
    // Nose
    final nosePaint = Paint()..color = const Color(0xFFE87A7A);
    final noseCenter = Offset(center.dx, center.dy + radius * 0.12);
    final nosePath = Path()
      ..moveTo(noseCenter.dx - 5, noseCenter.dy)
      ..lineTo(noseCenter.dx + 5, noseCenter.dy)
      ..lineTo(noseCenter.dx, noseCenter.dy + 5)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(noseCenter.dx - 8, noseCenter.dy + 9);
    mouthPath.quadraticBezierTo(noseCenter.dx - 4, noseCenter.dy + 12, noseCenter.dx, noseCenter.dy + 7);
    mouthPath.quadraticBezierTo(noseCenter.dx + 4, noseCenter.dy + 12, noseCenter.dx + 8, noseCenter.dy + 9);
    canvas.drawPath(mouthPath, mouthPaint);

    // Whiskers (Râu mèo)
    final whiskerPaint = Paint()
      ..color = const Color(0xFF4A3728).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(Offset(center.dx - radius * 0.45, center.dy + radius * 0.1), Offset(center.dx - radius * 0.85, center.dy + radius * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.dx - radius * 0.45, center.dy + radius * 0.18), Offset(center.dx - radius * 0.82, center.dy + radius * 0.22), whiskerPaint);

    // Right whiskers
    canvas.drawLine(Offset(center.dx + radius * 0.45, center.dy + radius * 0.1), Offset(center.dx + radius * 0.85, center.dy + radius * 0.05), whiskerPaint);
    canvas.drawLine(Offset(center.dx + radius * 0.45, center.dy + radius * 0.18), Offset(center.dx + radius * 0.82, center.dy + radius * 0.22), whiskerPaint);
  }

  void _drawPaws(Canvas canvas, Offset center, double radius) {
    final pawPaint = Paint()..color = bodyColor;
    final pawBorder = Paint()
      ..color = const Color(0xFF4A3728).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final leftPaw = Offset(center.dx - radius * 0.45, center.dy + radius * 0.78);
    final rightPaw = Offset(center.dx + radius * 0.45, center.dy + radius * 0.78);

    canvas.drawOval(Rect.fromCenter(center: leftPaw, width: radius * 0.38, height: radius * 0.28), pawPaint);
    canvas.drawOval(Rect.fromCenter(center: leftPaw, width: radius * 0.38, height: radius * 0.28), pawBorder);

    canvas.drawOval(Rect.fromCenter(center: rightPaw, width: radius * 0.38, height: radius * 0.28), pawPaint);
    canvas.drawOval(Rect.fromCenter(center: rightPaw, width: radius * 0.38, height: radius * 0.28), pawBorder);
  }

  void _drawCollarAndPouch(Canvas canvas, Offset center, double radius) {
    // Red collar string
    final collarPaint = Paint()
      ..color = const Color(0xFFE63946)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final collarPath = Path()
      ..moveTo(center.dx - radius * 0.5, center.dy + radius * 0.6)
      ..quadraticBezierTo(center.dx, center.dy + radius * 0.75, center.dx + radius * 0.5, center.dy + radius * 0.6);
    canvas.drawPath(collarPath, collarPaint);

    // Golden coin pouch (Túi tiền nhỏ ở cổ theo Mục 3.1)
    final pouchCenter = Offset(center.dx, center.dy + radius * 0.72);
    final pouchPaint = Paint()..color = const Color(0xFFFFB703);
    canvas.drawCircle(pouchCenter, radius * 0.14, pouchPaint);

    // Pouch tie string
    final tiePaint = Paint()..color = const Color(0xFFE63946);
    canvas.drawCircle(Offset(pouchCenter.dx, pouchCenter.dy - radius * 0.12), radius * 0.04, tiePaint);

    // Coin symbol "Xu"
    final coinBorder = Paint()
      ..color = const Color(0xFFFB8500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pouchCenter, radius * 0.09, coinBorder);
  }

  void _drawGlasses(Canvas canvas, Offset center, double radius) {
    final framePaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final leftCenter = Offset(center.dx - radius * 0.36, center.dy - radius * 0.05);
    final rightCenter = Offset(center.dx + radius * 0.36, center.dy - radius * 0.05);
    final frameRadius = radius * 0.22;

    canvas.drawCircle(leftCenter, frameRadius, framePaint);
    canvas.drawCircle(rightCenter, frameRadius, framePaint);
    canvas.drawLine(
      Offset(leftCenter.dx + frameRadius, leftCenter.dy),
      Offset(rightCenter.dx - frameRadius, rightCenter.dy),
      framePaint,
    );
  }

  void _drawBowTie(Canvas canvas, Offset center, double radius) {
    final bowCenter = Offset(center.dx, center.dy + radius * 0.58);
    final bowPaint = Paint()..color = const Color(0xFFE63946);

    final leftWing = Path()
      ..moveTo(bowCenter.dx, bowCenter.dy)
      ..lineTo(bowCenter.dx - 16, bowCenter.dy - 8)
      ..lineTo(bowCenter.dx - 16, bowCenter.dy + 8)
      ..close();
    final rightWing = Path()
      ..moveTo(bowCenter.dx, bowCenter.dy)
      ..lineTo(bowCenter.dx + 16, bowCenter.dy - 8)
      ..lineTo(bowCenter.dx + 16, bowCenter.dy + 8)
      ..close();

    canvas.drawPath(leftWing, bowPaint);
    canvas.drawPath(rightWing, bowPaint);
    canvas.drawCircle(bowCenter, 4, Paint()..color = const Color(0xFFBA181B));
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.wagAngle != wagAngle ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.breed != breed ||
        oldDelegate.accessories != accessories ||
        oldDelegate.animProgress != animProgress;
  }
}
