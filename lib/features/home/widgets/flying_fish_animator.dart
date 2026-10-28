import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlyingFishParticle {
  final Offset startOffset;
  final Offset targetOffset;
  final Offset controlPoint;
  final String symbol;
  final double scale;
  final double rotation;
  final int delayMs;

  FlyingFishParticle({
    required this.startOffset,
    required this.targetOffset,
    required this.controlPoint,
    this.symbol = '🐟',
    this.scale = 1.0,
    this.rotation = 0.0,
    this.delayMs = 0,
  });
}

class FlyingFishOverlay extends StatefulWidget {
  final Widget child;

  const FlyingFishOverlay({super.key, required this.child});

  static FlyingFishOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<FlyingFishOverlayState>();
  }

  @override
  State<FlyingFishOverlay> createState() => FlyingFishOverlayState();
}

class FlyingFishOverlayState extends State<FlyingFishOverlay>
    with TickerProviderStateMixin {
  final List<_ActiveFlight> _activeFlights = [];
  final math.Random _random = math.Random();

  void shootFish({
    required Offset start,
    required Offset target,
    int count = 5,
    VoidCallback? onReachedTarget,
  }) {
    HapticFeedback.lightImpact();

    final flightId = DateTime.now().microsecondsSinceEpoch.toString();
    final particles = <FlyingFishParticle>[];

    // Compute curved trajectory with random arch
    final midX = (start.dx + target.dx) / 2;
    final midY = math.min(start.dy, target.dy) - (70 + _random.nextDouble() * 60);

    for (int i = 0; i < count; i++) {
      final curveOffsetX = (_random.nextDouble() - 0.5) * 80;
      final controlPoint = Offset(midX + curveOffsetX, midY);

      particles.add(
        FlyingFishParticle(
          startOffset: start + Offset((_random.nextDouble() - 0.5) * 30, (_random.nextDouble() - 0.5) * 20),
          targetOffset: target + Offset((_random.nextDouble() - 0.5) * 20, (_random.nextDouble() - 0.5) * 20),
          controlPoint: controlPoint,
          symbol: i % 3 == 0 ? '✨' : '🐟',
          scale: 0.85 + _random.nextDouble() * 0.45,
          rotation: (_random.nextDouble() - 0.5) * math.pi,
          delayMs: i * 80,
        ),
      );
    }

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    final flight = _ActiveFlight(
      id: flightId,
      particles: particles,
      controller: controller,
      onReachedTarget: onReachedTarget,
    );

    setState(() {
      _activeFlights.add(flight);
    });

    controller.forward().then((_) {
      HapticFeedback.mediumImpact();
      onReachedTarget?.call();
      if (mounted) {
        setState(() {
          _activeFlights.removeWhere((f) => f.id == flightId);
        });
      }
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_activeFlights.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: _activeFlights.map((flight) {
                  return AnimatedBuilder(
                    animation: flight.controller,
                    builder: (context, _) {
                      return Stack(
                        children: flight.particles.map((particle) {
                          // Compute staggered progress
                          final totalMs = 950.0;
                          final elapsedMs = flight.controller.value * totalMs;
                          final particleElapsed = math.max(0.0, elapsedMs - particle.delayMs);
                          final durationMs = totalMs - particle.delayMs;
                          final progress = (particleElapsed / durationMs).clamp(0.0, 1.0);

                          if (progress <= 0.0 || progress >= 1.0) {
                            return const SizedBox.shrink();
                          }

                          // Quadratic Bezier interpolation: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2
                          final t = Curves.easeInOutCubic.transform(progress);
                          final p0 = particle.startOffset;
                          final p1 = particle.controlPoint;
                          final p2 = particle.targetOffset;

                          final x = (1 - t) * (1 - t) * p0.dx +
                              2 * (1 - t) * t * p1.dx +
                              t * t * p2.dx;
                          final y = (1 - t) * (1 - t) * p0.dy +
                              2 * (1 - t) * t * p1.dy +
                              t * t * p2.dy;

                          // Scale & Fade curve
                          final scale = particle.scale * (1.0 + math.sin(t * math.pi) * 0.4);
                          final opacity = progress > 0.85 ? (1.0 - (progress - 0.85) / 0.15) : 1.0;

                          return Positioned(
                            left: x - 14,
                            top: y - 14,
                            child: Opacity(
                              opacity: opacity.clamp(0.0, 1.0),
                              child: Transform.rotate(
                                angle: particle.rotation + progress * math.pi * 2,
                                child: Transform.scale(
                                  scale: scale,
                                  child: Text(
                                    particle.symbol,
                                    style: TextStyle(
                                      fontSize: particle.symbol == '✨' ? 18 : 22,
                                      shadows: const [
                                        Shadow(
                                          color: Color(0x66FFB703),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveFlight {
  final String id;
  final List<FlyingFishParticle> particles;
  final AnimationController controller;
  final VoidCallback? onReachedTarget;

  _ActiveFlight({
    required this.id,
    required this.particles,
    required this.controller,
    this.onReachedTarget,
  });
}
