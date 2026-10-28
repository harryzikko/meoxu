import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/cat_state.dart';

class MeoMascotWidget extends StatefulWidget {
  final CatMood mood;
  final String breed; // 'orange', 'tabby', 'calico', 'black', 'white', 'siamese', 'tuxedo'
  final String eyeColor; // 'amber', 'ocean_blue', 'emerald', 'heterochromia'
  final List<String> equippedAccessories;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onPet;
  final bool enablePetting;

  const MeoMascotWidget({
    super.key,
    this.mood = CatMood.happy,
    this.breed = 'orange',
    this.eyeColor = 'amber',
    this.equippedAccessories = const [],
    this.size = 180.0,
    this.onTap,
    this.onPet,
    this.enablePetting = true,
  });

  @override
  State<MeoMascotWidget> createState() => _MeoMascotWidgetState();
}

class _MeoMascotWidgetState extends State<MeoMascotWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _petController;
  late AnimationController _blinkController;

  late Animation<double> _wagAnimation;
  late Animation<double> _breatheAnimation;
  late Animation<double> _squishAnimation;
  late Animation<double> _earTwitchAnimation;

  final List<_FloatingHeart> _hearts = [];
  final math.Random _random = math.Random();
  bool _isPettingActive = false;

  @override
  void initState() {
    super.initState();

    // 1. Idle breathing & tail wag
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _wagAnimation = Tween<double>(
      begin: -0.18,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

    _breatheAnimation = Tween<double>(
      begin: 0.985,
      end: 1.025,
    ).animate(CurvedAnimation(parent: _idleController, curve: Curves.easeInOut));

    _earTwitchAnimation = Tween<double>(
      begin: 0.0,
      end: 0.08,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: const Interval(0.7, 0.9, curve: Curves.elasticOut),
    ));

    // 2. Petting squish & bounce animation
    _petController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _squishAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.92), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _petController, curve: Curves.easeOut));

    _petController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isPettingActive = false;
          });
        }
      }
    });

    // 3. Natural periodic blinking
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _petController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _triggerPetting([Offset? localPosition]) {
    if (!widget.enablePetting) {
      widget.onTap?.call();
      return;
    }

    // Haptic purr feedback
    HapticFeedback.lightImpact();

    // Trigger bounce
    _petController.forward(from: 0.0);

    // Spawn floating hearts & sparkles
    final spawnX = localPosition?.dx ?? (widget.size / 2);
    final spawnY = localPosition?.dy ?? (widget.size * 0.45);

    final symbols = ['♥', '✨', '🐾', '♥', '🌸'];
    for (int i = 0; i < 4; i++) {
      _hearts.add(
        _FloatingHeart(
          x: spawnX + (_random.nextDouble() - 0.5) * 45,
          y: spawnY + (_random.nextDouble() - 0.5) * 20,
          symbol: symbols[_random.nextInt(symbols.length)],
          color: i % 2 == 0 ? const Color(0xFFFF6584) : const Color(0xFFFFB703),
          size: 16.0 + _random.nextDouble() * 10,
          vx: (_random.nextDouble() - 0.5) * 35,
          vy: -50.0 - _random.nextDouble() * 40,
        ),
      );
    }

    setState(() {
      _isPettingActive = true;
    });

    widget.onPet?.call();
    widget.onTap?.call();
  }

  Color get _catBodyColor {
    switch (widget.breed) {
      case 'orange':
        return const Color(0xFFFFB26B);
      case 'tabby':
        return const Color(0xFFC7A788);
      case 'calico':
        return const Color(0xFFFFF9EE);
      case 'black':
        return const Color(0xFF38353B);
      case 'white':
        return const Color(0xFFFAF7F2);
      case 'siamese':
        return const Color(0xFFF2E6D8);
      case 'tuxedo':
        return const Color(0xFF2C2F33);
      default:
        return const Color(0xFFFFB26B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _triggerPetting(details.localPosition),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Mascot Animated Custom Paint
            AnimatedBuilder(
              animation: Listenable.merge([
                _idleController,
                _petController,
                _blinkController,
              ]),
              builder: (context, child) {
                final isDancing = widget.mood == CatMood.dancing;
                final danceOffset = isDancing
                    ? math.sin(_idleController.value * math.pi * 4) * 8.0
                    : 0.0;

                final squishScale = _squishAnimation.value;
                final breatheScale = _breatheAnimation.value;

                // Blink phase: blink closed briefly around 90-95% of cycle
                final blinkProgress = _blinkController.value;
                final isBlinking = blinkProgress > 0.92 && blinkProgress < 0.97;

                return Transform.translate(
                  offset: Offset(0, danceOffset),
                  child: Transform.scale(
                    scaleX: breatheScale * (squishScale > 1.0 ? 1.08 : 1.0),
                    scaleY: breatheScale * (squishScale > 1.0 ? 0.93 : 1.0),
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _CatPainter(
                        mood: widget.mood,
                        bodyColor: _catBodyColor,
                        wagAngle: _wagAnimation.value,
                        earTwitch: _earTwitchAnimation.value,
                        breed: widget.breed,
                        eyeColor: widget.eyeColor,
                        accessories: widget.equippedAccessories,
                        animProgress: _idleController.value,
                        isPetting: _isPettingActive,
                        isBlinking: isBlinking,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Floating Hearts Particle Overlay
            ..._hearts.map((heart) {
              return _AnimatedParticleWidget(
                heart: heart,
                onComplete: () {
                  setState(() {
                    _hearts.remove(heart);
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FloatingHeart {
  final double x;
  final double y;
  final String symbol;
  final Color color;
  final double size;
  final double vx;
  final double vy;

  _FloatingHeart({
    required this.x,
    required this.y,
    required this.symbol,
    required this.color,
    required this.size,
    required this.vx,
    required this.vy,
  });
}

class _AnimatedParticleWidget extends StatefulWidget {
  final _FloatingHeart heart;
  final VoidCallback onComplete;

  const _AnimatedParticleWidget({
    required this.heart,
    required this.onComplete,
  });

  @override
  State<_AnimatedParticleWidget> createState() =>
      _AnimatedParticleWidgetState();
}

class _AnimatedParticleWidgetState extends State<_AnimatedParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0)),
    );

    _scale = Tween<double>(begin: 0.5, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        final posX = widget.heart.x + widget.heart.vx * t;
        final posY = widget.heart.y + widget.heart.vy * t;

        return Positioned(
          left: posX,
          top: posY,
          child: Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.heart.symbol,
                style: TextStyle(
                  fontSize: widget.heart.size,
                  color: widget.heart.color,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CatPainter extends CustomPainter {
  final CatMood mood;
  final Color bodyColor;
  final double wagAngle;
  final double earTwitch;
  final String breed;
  final String eyeColor;
  final List<String> accessories;
  final double animProgress;
  final bool isPetting;
  final bool isBlinking;

  _CatPainter({
    required this.mood,
    required this.bodyColor,
    required this.wagAngle,
    required this.earTwitch,
    required this.breed,
    required this.eyeColor,
    required this.accessories,
    required this.animProgress,
    required this.isPetting,
    required this.isBlinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.36;

    // 1. Soft Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.95),
        width: radius * 1.85,
        height: radius * 0.36,
      ),
      shadowPaint,
    );

    // 2. Animated Tail
    _drawTail(canvas, center, radius);

    // 3. Cute Ears
    _drawEars(canvas, center, radius);

    // 4. Cat Body & Silhouette
    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawCircle(center, radius, bodyPaint);

    // Breed specific coat markings & bibs
    _drawCoatMarkings(canvas, center, radius);

    // Subtle outline for depth
    final outlinePaint = Paint()
      ..color = const Color(0xFF3E2723).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius, outlinePaint);

    // 5. Rosy Cheeks (Blushing brighter when petted)
    final blushAlpha = isPetting ? 0.75 : 0.45;
    final blushPaint = Paint()
      ..color = const Color(0xFFFF85A1).withOpacity(blushAlpha);
    final blushRadius = radius * (isPetting ? 0.18 : 0.14);

    canvas.drawCircle(
      Offset(center.dx - radius * 0.52, center.dy + radius * 0.18),
      blushRadius,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.52, center.dy + radius * 0.18),
      blushRadius,
      blushPaint,
    );

    // 6. Eyes based on Mood, Personality & Blinking
    _drawEyes(canvas, center, radius);

    // 7. Cute Nose, Mouth & Whiskers
    _drawNoseAndWhiskers(canvas, center, radius);

    // 8. Chubby Paws
    _drawPaws(canvas, center, radius);

    // 9. Collar with Golden Coin Pouch (if equipped or default)
    if (accessories.contains('bell_collar') || accessories.isEmpty) {
      _drawCollarAndPouch(canvas, center, radius);
    }

    // 10. Accessories
    if (accessories.contains('bow_tie')) {
      _drawBowTie(canvas, center, radius);
    }
    if (accessories.contains('warm_scarf')) {
      _drawScarf(canvas, center, radius);
    }
    if (accessories.contains('glasses')) {
      _drawGlasses(canvas, center, radius);
    }
    if (accessories.contains('sunglasses')) {
      _drawSunglasses(canvas, center, radius);
    }
    if (accessories.contains('chef_hat')) {
      _drawChefHat(canvas, center, radius);
    }
    if (accessories.contains('wizard_hat')) {
      _drawWizardHat(canvas, center, radius);
    }
    if (accessories.contains('flower_crown')) {
      _drawFlowerCrown(canvas, center, radius);
    }
    if (accessories.contains('fish_mouth')) {
      _drawFishInMouth(canvas, center, radius);
    }
  }

  void _drawTail(Canvas canvas, Offset center, double radius) {
    Color tailColor = bodyColor;
    if (breed == 'siamese') tailColor = const Color(0xFF5D4037);

    final tailPaint = Paint()
      ..color = tailColor
      ..strokeWidth = radius * 0.22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final start = Offset(center.dx + radius * 0.75, center.dy + radius * 0.5);
    final end = Offset(
      center.dx + radius * 1.25 + math.sin(wagAngle) * 16,
      center.dy - radius * 0.12 + math.cos(wagAngle) * 12,
    );

    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(
      center.dx + radius * 1.1,
      center.dy + radius * 0.28,
      end.dx,
      end.dy,
    );
    canvas.drawPath(path, tailPaint);
  }

  void _drawEars(Canvas canvas, Offset center, double radius) {
    Color leftEarColor = bodyColor;
    Color rightEarColor = bodyColor;

    if (breed == 'calico') {
      leftEarColor = const Color(0xFFFF9F43);
      rightEarColor = const Color(0xFF4A4440);
    } else if (breed == 'siamese') {
      leftEarColor = const Color(0xFF5D4037);
      rightEarColor = const Color(0xFF5D4037);
    }

    final earInnerPaint = Paint()..color = const Color(0xFFFFC0BD);

    // Left ear with twitch
    final leftEarPaint = Paint()..color = leftEarColor;
    final leftTwitchOffset = earTwitch * radius;
    final leftEarPath = Path()
      ..moveTo(center.dx - radius * 0.8, center.dy - radius * 0.3)
      ..lineTo(
        center.dx - radius * 0.65 - leftTwitchOffset,
        center.dy - radius * 1.05 + leftTwitchOffset,
      )
      ..lineTo(center.dx - radius * 0.15, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(leftEarPath, leftEarPaint);

    final leftInner = Path()
      ..moveTo(center.dx - radius * 0.72, center.dy - radius * 0.35)
      ..lineTo(
        center.dx - radius * 0.62 - leftTwitchOffset,
        center.dy - radius * 0.95 + leftTwitchOffset,
      )
      ..lineTo(center.dx - radius * 0.25, center.dy - radius * 0.75)
      ..close();
    canvas.drawPath(leftInner, earInnerPaint);

    // Right ear
    final rightEarPaint = Paint()..color = rightEarColor;
    final rightEarPath = Path()
      ..moveTo(center.dx + radius * 0.8, center.dy - radius * 0.3)
      ..lineTo(center.dx + radius * 0.65, center.dy - radius * 1.05)
      ..lineTo(center.dx + radius * 0.15, center.dy - radius * 0.8)
      ..close();
    canvas.drawPath(rightEarPath, rightEarPaint);

    final rightInner = Path()
      ..moveTo(center.dx + radius * 0.72, center.dy - radius * 0.35)
      ..lineTo(center.dx + radius * 0.62, center.dy - radius * 0.95)
      ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.75)
      ..close();
    canvas.drawPath(rightInner, earInnerPaint);
  }

  void _drawCoatMarkings(Canvas canvas, Offset center, double radius) {
    if (breed == 'orange' || breed == 'tabby') {
      final stripeColor = breed == 'orange'
          ? const Color(0xFFE58D43).withOpacity(0.45)
          : const Color(0xFF8D6E63).withOpacity(0.5);

      final stripePaint = Paint()
        ..color = stripeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      // Forehead stripes (M shape)
      canvas.drawLine(
        Offset(center.dx, center.dy - radius * 0.85),
        Offset(center.dx, center.dy - radius * 0.58),
        stripePaint,
      );
      canvas.drawLine(
        Offset(center.dx - 13, center.dy - radius * 0.8),
        Offset(center.dx - 9, center.dy - radius * 0.58),
        stripePaint,
      );
      canvas.drawLine(
        Offset(center.dx + 13, center.dy - radius * 0.8),
        Offset(center.dx + 9, center.dy - radius * 0.58),
        stripePaint,
      );

      // Cream chest patch
      final bibPaint = Paint()..color = const Color(0xFFFFF7ED).withOpacity(0.85);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.55),
          width: radius * 0.75,
          height: radius * 0.45,
        ),
        bibPaint,
      );
    } else if (breed == 'tuxedo') {
      // Tuxedo white triangular chest bib & muzzle
      final bibPaint = Paint()..color = Colors.white;
      final bibPath = Path()
        ..moveTo(center.dx - radius * 0.45, center.dy + radius * 0.3)
        ..lineTo(center.dx, center.dy + radius * 0.85)
        ..lineTo(center.dx + radius * 0.45, center.dy + radius * 0.3)
        ..quadraticBezierTo(center.dx, center.dy + radius * 0.15, center.dx - radius * 0.45, center.dy + radius * 0.3)
        ..close();
      canvas.drawPath(bibPath, bibPaint);

      // White muzzle
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.15),
          width: radius * 0.52,
          height: radius * 0.32,
        ),
        bibPaint,
      );
    } else if (breed == 'siamese') {
      // Dark chocolate face mask
      final maskPaint = Paint()..color = const Color(0xFF5D4037).withOpacity(0.88);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.08),
          width: radius * 0.85,
          height: radius * 0.62,
        ),
        maskPaint,
      );
    } else if (breed == 'calico') {
      // Cute patchwork spots
      final orangePatch = Paint()..color = const Color(0xFFFF9F43);
      final blackPatch = Paint()..color = const Color(0xFF4A4440);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx - radius * 0.55, center.dy - radius * 0.4),
          width: radius * 0.45,
          height: radius * 0.35,
        ),
        orangePatch,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.52, center.dy - radius * 0.35),
          width: radius * 0.42,
          height: radius * 0.38,
        ),
        blackPatch,
      );
    }
  }

  Color _resolveEyeColor(bool isLeftEye) {
    if (eyeColor == 'heterochromia') {
      // Left eye is Ocean Blue, Right eye is Honey Amber
      return isLeftEye ? const Color(0xFF00B4D8) : const Color(0xFFF39C12);
    }
    switch (eyeColor) {
      case 'ocean_blue':
        return const Color(0xFF00B4D8);
      case 'emerald':
        return const Color(0xFF2ECC71);
      case 'amber':
      default:
        return const Color(0xFFF39C12);
    }
  }

  void _drawEyes(Canvas canvas, Offset center, double radius) {
    final leftEyeCenter = Offset(
      center.dx - radius * 0.36,
      center.dy - radius * 0.05,
    );
    final rightEyeCenter = Offset(
      center.dx + radius * 0.36,
      center.dy - radius * 0.05,
    );

    // 1. Purring (when petted) or Happy/Dancing: squinted happy curved lines `^ . ^`
    if (isPetting || mood == CatMood.purring || mood == CatMood.happy || mood == CatMood.dancing) {
      final happyPaint = Paint()
        ..color = const Color(0xFF2C221E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round;

      final pLeft = Path()
        ..moveTo(leftEyeCenter.dx - 12, leftEyeCenter.dy + 2)
        ..quadraticBezierTo(
          leftEyeCenter.dx,
          leftEyeCenter.dy - 11,
          leftEyeCenter.dx + 12,
          leftEyeCenter.dy + 2,
        );
      final pRight = Path()
        ..moveTo(rightEyeCenter.dx - 12, rightEyeCenter.dy + 2)
        ..quadraticBezierTo(
          rightEyeCenter.dx,
          rightEyeCenter.dy - 11,
          rightEyeCenter.dx + 12,
          rightEyeCenter.dy + 2,
        );

      canvas.drawPath(pLeft, happyPaint);
      canvas.drawPath(pRight, happyPaint);
      return;
    }

    // 2. Sleeping or periodic natural blink
    if (mood == CatMood.sleeping || isBlinking) {
      final sleepPaint = Paint()
        ..color = const Color(0xFF2C221E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;

      final pLeft = Path()
        ..moveTo(leftEyeCenter.dx - 11, leftEyeCenter.dy)
        ..quadraticBezierTo(
          leftEyeCenter.dx,
          leftEyeCenter.dy - 6,
          leftEyeCenter.dx + 11,
          leftEyeCenter.dy,
        );
      final pRight = Path()
        ..moveTo(rightEyeCenter.dx - 11, rightEyeCenter.dy)
        ..quadraticBezierTo(
          rightEyeCenter.dx,
          rightEyeCenter.dy - 6,
          rightEyeCenter.dx + 11,
          rightEyeCenter.dy,
        );

      canvas.drawPath(pLeft, sleepPaint);
      canvas.drawPath(pRight, sleepPaint);
      return;
    }

    // 3. Big sparkling open eyes with custom eye color iris
    final eyeRadius = radius * 0.16;
    final pupilRadius = eyeRadius * 0.65;

    // Draw Left Eye
    final leftColor = _resolveEyeColor(true);
    final leftIrisPaint = Paint()..color = leftColor;
    final pupilPaint = Paint()..color = const Color(0xFF1E1715);
    final eyeWhite = Paint()..color = Colors.white;

    canvas.drawCircle(leftEyeCenter, eyeRadius, leftIrisPaint);
    canvas.drawCircle(leftEyeCenter, pupilRadius, pupilPaint);
    // Highlights
    canvas.drawCircle(
      Offset(leftEyeCenter.dx - 3, leftEyeCenter.dy - 4),
      eyeRadius * 0.38,
      eyeWhite,
    );
    canvas.drawCircle(
      Offset(leftEyeCenter.dx + 3.5, leftEyeCenter.dy + 3),
      eyeRadius * 0.18,
      eyeWhite,
    );

    // Draw Right Eye
    final rightColor = _resolveEyeColor(false);
    final rightIrisPaint = Paint()..color = rightColor;

    canvas.drawCircle(rightEyeCenter, eyeRadius, rightIrisPaint);
    canvas.drawCircle(rightEyeCenter, pupilRadius, pupilPaint);
    // Highlights
    canvas.drawCircle(
      Offset(rightEyeCenter.dx - 3, rightEyeCenter.dy - 4),
      eyeRadius * 0.38,
      eyeWhite,
    );
    canvas.drawCircle(
      Offset(rightEyeCenter.dx + 3.5, rightEyeCenter.dy + 3),
      eyeRadius * 0.18,
      eyeWhite,
    );

    // Excited sparkle star in pupil
    if (mood == CatMood.excited) {
      canvas.drawCircle(
        Offset(leftEyeCenter.dx + 2, leftEyeCenter.dy - 1),
        eyeRadius * 0.22,
        eyeWhite,
      );
      canvas.drawCircle(
        Offset(rightEyeCenter.dx + 2, rightEyeCenter.dy - 1),
        eyeRadius * 0.22,
        eyeWhite,
      );
    }
  }

  void _drawNoseAndWhiskers(Canvas canvas, Offset center, double radius) {
    // Nose
    final nosePaint = Paint()..color = const Color(0xFFE87A7A);
    final noseCenter = Offset(center.dx, center.dy + radius * 0.12);
    final nosePath = Path()
      ..moveTo(noseCenter.dx - 5.5, noseCenter.dy)
      ..lineTo(noseCenter.dx + 5.5, noseCenter.dy)
      ..lineTo(noseCenter.dx, noseCenter.dy + 5.5)
      ..close();
    canvas.drawPath(nosePath, nosePaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    mouthPath.moveTo(noseCenter.dx - 9, noseCenter.dy + 10);
    mouthPath.quadraticBezierTo(
      noseCenter.dx - 4.5,
      noseCenter.dy + 13,
      noseCenter.dx,
      noseCenter.dy + 7,
    );
    mouthPath.quadraticBezierTo(
      noseCenter.dx + 4.5,
      noseCenter.dy + 13,
      noseCenter.dx + 9,
      noseCenter.dy + 10,
    );
    canvas.drawPath(mouthPath, mouthPaint);

    // Whiskers (White on black cat, brown on others)
    final isDarkCat = breed == 'black';
    final whiskerPaint = Paint()
      ..color = isDarkCat
          ? Colors.white.withOpacity(0.7)
          : const Color(0xFF4A3728).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(
      Offset(center.dx - radius * 0.45, center.dy + radius * 0.1),
      Offset(center.dx - radius * 0.88, center.dy + radius * 0.05),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius * 0.45, center.dy + radius * 0.18),
      Offset(center.dx - radius * 0.85, center.dy + radius * 0.22),
      whiskerPaint,
    );

    // Right whiskers
    canvas.drawLine(
      Offset(center.dx + radius * 0.45, center.dy + radius * 0.1),
      Offset(center.dx + radius * 0.88, center.dy + radius * 0.05),
      whiskerPaint,
    );
    canvas.drawLine(
      Offset(center.dx + radius * 0.45, center.dy + radius * 0.18),
      Offset(center.dx + radius * 0.85, center.dy + radius * 0.22),
      whiskerPaint,
    );
  }

  void _drawPaws(Canvas canvas, Offset center, double radius) {
    Color pawColor = bodyColor;
    if (breed == 'tuxedo' || breed == 'orange') {
      pawColor = Colors.white;
    } else if (breed == 'siamese') {
      pawColor = const Color(0xFF5D4037);
    }

    final pawPaint = Paint()..color = pawColor;
    final pawBorder = Paint()
      ..color = const Color(0xFF4A3728).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final leftPaw = Offset(
      center.dx - radius * 0.45,
      center.dy + radius * 0.78,
    );
    final rightPaw = Offset(
      center.dx + radius * 0.45,
      center.dy + radius * 0.78,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: leftPaw,
        width: radius * 0.38,
        height: radius * 0.28,
      ),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: leftPaw,
        width: radius * 0.38,
        height: radius * 0.28,
      ),
      pawBorder,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: rightPaw,
        width: radius * 0.38,
        height: radius * 0.28,
      ),
      pawPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: rightPaw,
        width: radius * 0.38,
        height: radius * 0.28,
      ),
      pawBorder,
    );
  }

  void _drawCollarAndPouch(Canvas canvas, Offset center, double radius) {
    final collarPaint = Paint()
      ..color = const Color(0xFFE63946)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final collarPath = Path()
      ..moveTo(center.dx - radius * 0.5, center.dy + radius * 0.6)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.75,
        center.dx + radius * 0.5,
        center.dy + radius * 0.6,
      );
    canvas.drawPath(collarPath, collarPaint);

    // Golden Coin Pouch
    final pouchCenter = Offset(center.dx, center.dy + radius * 0.72);
    final pouchPaint = Paint()..color = const Color(0xFFFFB703);
    canvas.drawCircle(pouchCenter, radius * 0.14, pouchPaint);

    final tiePaint = Paint()..color = const Color(0xFFE63946);
    canvas.drawCircle(
      Offset(pouchCenter.dx, pouchCenter.dy - radius * 0.12),
      radius * 0.04,
      tiePaint,
    );

    final coinBorder = Paint()
      ..color = const Color(0xFFFB8500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(pouchCenter, radius * 0.09, coinBorder);
  }

  void _drawBowTie(Canvas canvas, Offset center, double radius) {
    final bowCenter = Offset(center.dx, center.dy + radius * 0.6);
    final bowPaint = Paint()..color = const Color(0xFFE63946);

    final leftWing = Path()
      ..moveTo(bowCenter.dx, bowCenter.dy)
      ..lineTo(bowCenter.dx - 18, bowCenter.dy - 10)
      ..lineTo(bowCenter.dx - 18, bowCenter.dy + 10)
      ..close();
    final rightWing = Path()
      ..moveTo(bowCenter.dx, bowCenter.dy)
      ..lineTo(bowCenter.dx + 18, bowCenter.dy - 10)
      ..lineTo(bowCenter.dx + 18, bowCenter.dy + 10)
      ..close();

    canvas.drawPath(leftWing, bowPaint);
    canvas.drawPath(rightWing, bowPaint);
    canvas.drawCircle(bowCenter, 5, Paint()..color = const Color(0xFFBA181B));
  }

  void _drawGlasses(Canvas canvas, Offset center, double radius) {
    final framePaint = Paint()
      ..color = const Color(0xFF2B2D42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final leftCenter = Offset(
      center.dx - radius * 0.36,
      center.dy - radius * 0.05,
    );
    final rightCenter = Offset(
      center.dx + radius * 0.36,
      center.dy - radius * 0.05,
    );
    final frameRadius = radius * 0.22;

    canvas.drawCircle(leftCenter, frameRadius, framePaint);
    canvas.drawCircle(rightCenter, frameRadius, framePaint);
    canvas.drawLine(
      Offset(leftCenter.dx + frameRadius, leftCenter.dy),
      Offset(rightCenter.dx - frameRadius, rightCenter.dy),
      framePaint,
    );
  }

  void _drawSunglasses(Canvas canvas, Offset center, double radius) {
    final glassPaint = Paint()..color = const Color(0xFF1E2022);
    final glarePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftCenter = Offset(
      center.dx - radius * 0.36,
      center.dy - radius * 0.05,
    );
    final rightCenter = Offset(
      center.dx + radius * 0.36,
      center.dy - radius * 0.05,
    );

    // Left lens
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: leftCenter,
          width: radius * 0.44,
          height: radius * 0.36,
        ),
        const Radius.circular(8),
      ),
      glassPaint,
    );
    // Right lens
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rightCenter,
          width: radius * 0.44,
          height: radius * 0.36,
        ),
        const Radius.circular(8),
      ),
      glassPaint,
    );

    // Bridge
    final bridgePaint = Paint()
      ..color = const Color(0xFF1E2022)
      ..strokeWidth = 3.5;
    canvas.drawLine(
      Offset(leftCenter.dx + radius * 0.2, leftCenter.dy - 3),
      Offset(rightCenter.dx - radius * 0.2, rightCenter.dy - 3),
      bridgePaint,
    );

    // Glare lines
    canvas.drawLine(
      Offset(leftCenter.dx - 8, leftCenter.dy - 8),
      Offset(leftCenter.dx - 3, leftCenter.dy + 8),
      glarePaint,
    );
    canvas.drawLine(
      Offset(rightCenter.dx - 8, rightCenter.dy - 8),
      Offset(rightCenter.dx - 3, rightCenter.dy + 8),
      glarePaint,
    );
  }

  void _drawChefHat(Canvas canvas, Offset center, double radius) {
    final hatPaint = Paint()..color = Colors.white;
    final outlinePaint = Paint()
      ..color = const Color(0xFFB0BEC5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final hatCenter = Offset(center.dx, center.dy - radius * 0.88);

    // Puffy cloud top
    canvas.drawCircle(Offset(hatCenter.dx - 18, hatCenter.dy - 12), 16, hatPaint);
    canvas.drawCircle(Offset(hatCenter.dx + 18, hatCenter.dy - 12), 16, hatPaint);
    canvas.drawCircle(Offset(hatCenter.dx, hatCenter.dy - 20), 20, hatPaint);

    // Base band
    final baseRect = Rect.fromCenter(
      center: Offset(hatCenter.dx, hatCenter.dy + 2),
      width: radius * 0.7,
      height: 14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(4)),
      hatPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(baseRect, const Radius.circular(4)),
      outlinePaint,
    );
  }

  void _drawWizardHat(Canvas canvas, Offset center, double radius) {
    final hatPaint = Paint()..color = const Color(0xFF5E35B1);
    final brimPaint = Paint()..color = const Color(0xFF4527A0);
    final starPaint = Paint()..color = const Color(0xFFFFD54F);

    final brimCenter = Offset(center.dx, center.dy - radius * 0.8);

    // Wide brim
    canvas.drawOval(
      Rect.fromCenter(
        center: brimCenter,
        width: radius * 1.1,
        height: radius * 0.3,
      ),
      brimPaint,
    );

    // Pointy cone
    final conePath = Path()
      ..moveTo(brimCenter.dx - radius * 0.4, brimCenter.dy)
      ..quadraticBezierTo(
        brimCenter.dx,
        brimCenter.dy - radius * 0.7,
        brimCenter.dx + radius * 0.25,
        brimCenter.dy - radius * 1.25,
      )
      ..lineTo(brimCenter.dx + radius * 0.38, brimCenter.dy)
      ..close();
    canvas.drawPath(conePath, hatPaint);

    // Star icon on hat
    canvas.drawCircle(
      Offset(brimCenter.dx - 2, brimCenter.dy - radius * 0.5),
      5.5,
      starPaint,
    );
  }

  void _drawFlowerCrown(Canvas canvas, Offset center, double radius) {
    final petalPaint = Paint()..color = Colors.white;
    final flowerCenterPaint = Paint()..color = const Color(0xFFFFB703);

    final positions = [
      Offset(center.dx - radius * 0.45, center.dy - radius * 0.75),
      Offset(center.dx - radius * 0.15, center.dy - radius * 0.88),
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.88),
      Offset(center.dx + radius * 0.45, center.dy - radius * 0.75),
    ];

    for (final pos in positions) {
      for (int i = 0; i < 5; i++) {
        final angle = (i * 2 * math.pi) / 5;
        final petalPos = Offset(
          pos.dx + math.cos(angle) * 7.5,
          pos.dy + math.sin(angle) * 7.5,
        );
        canvas.drawCircle(petalPos, 4.5, petalPaint);
      }
      canvas.drawCircle(pos, 4.0, flowerCenterPaint);
    }
  }

  void _drawFishInMouth(Canvas canvas, Offset center, double radius) {
    final fishPaint = Paint()..color = const Color(0xFF64B5F6);
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    final fishPos = Offset(center.dx + 8, center.dy + radius * 0.22);

    // Fish body oval
    canvas.drawOval(
      Rect.fromCenter(
        center: fishPos,
        width: radius * 0.52,
        height: radius * 0.22,
      ),
      fishPaint,
    );

    // Fish tail
    final tailPath = Path()
      ..moveTo(fishPos.dx + radius * 0.24, fishPos.dy)
      ..lineTo(fishPos.dx + radius * 0.38, fishPos.dy - 8)
      ..lineTo(fishPos.dx + radius * 0.38, fishPos.dy + 8)
      ..close();
    canvas.drawPath(tailPath, fishPaint);

    // Fish eye
    canvas.drawCircle(
      Offset(fishPos.dx - radius * 0.14, fishPos.dy - 2),
      3.2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(fishPos.dx - radius * 0.14, fishPos.dy - 2),
      1.6,
      pupilPaint,
    );
  }

  void _drawScarf(Canvas canvas, Offset center, double radius) {
    final scarfPaint = Paint()
      ..color = const Color(0xFFE76F51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final collarPath = Path()
      ..moveTo(center.dx - radius * 0.48, center.dy + radius * 0.58)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.72,
        center.dx + radius * 0.48,
        center.dy + radius * 0.58,
      );
    canvas.drawPath(collarPath, scarfPaint);

    // Hanging scarf tail
    final tailPaint = Paint()
      ..color = const Color(0xFFE76F51)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx + radius * 0.28, center.dy + radius * 0.65),
      Offset(center.dx + radius * 0.32, center.dy + radius * 0.95),
      tailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.wagAngle != wagAngle ||
        oldDelegate.earTwitch != earTwitch ||
        oldDelegate.bodyColor != bodyColor ||
        oldDelegate.breed != breed ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.accessories != accessories ||
        oldDelegate.animProgress != animProgress ||
        oldDelegate.isPetting != isPetting ||
        oldDelegate.isBlinking != isBlinking;
  }
}
