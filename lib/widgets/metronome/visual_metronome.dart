import 'package:flutter/material.dart';
import 'dart:math' as math;

class VisualMetronome extends StatelessWidget {
  final bool isPlaying;
  final bool isInitialized;
  final AnimationController pendulumController;
  final AnimationController visualBeatController;
  final AnimationController beatController;
  final int timeSignature;
  final int currentBeat;
  final int subdivision;
  final bool Function(int) shouldAccent;
  final VoidCallback toggleMetronome;

  const VisualMetronome({
    super.key,
    required this.isPlaying,
    required this.isInitialized,
    required this.pendulumController,
    required this.visualBeatController,
    required this.beatController,
    required this.timeSignature,
    required this.currentBeat,
    required this.subdivision,
    required this.shouldAccent,
    required this.toggleMetronome,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Container(
            width: double.infinity,
            height: 280, // Fixed height to prevent overflow
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced pendulum with base
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Pendulum base
                    Container(
                      width: 50,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Pendulum rod and bob
                    AnimatedBuilder(
                      animation: pendulumController,
                      builder: (context, child) {
                        final angle = isPlaying
                            ? math.sin(pendulumController.value * 2 * math.pi) *
                                0.5
                            : 0.0;
                        return Transform.rotate(
                          angle: angle,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pendulum bob
                              AnimatedBuilder(
                                animation: visualBeatController,
                                builder: (context, child) {
                                  final scale =
                                      1.0 + visualBeatController.value * 0.2;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isPlaying
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context).disabledColor,
                                        shape: BoxShape.circle,
                                        boxShadow: isPlaying
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Pendulum rod
                              Container(
                                width: 3,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B7280),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Enhanced beat indicators with subdivisions
                Column(
                  children: [
                    // Main beats
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(timeSignature, (index) {
                          return AnimatedBuilder(
                            animation: beatController,
                            builder: (context, child) {
                              final currentMainBeat =
                                  (currentBeat ~/ subdivision) % timeSignature;
                              final isCurrentBeat = index == currentMainBeat;
                              final isAccent = shouldAccent(index);

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCurrentBeat
                                      ? (isAccent
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary)
                                          .withOpacity(
                                              1.0 - beatController.value * 0.3)
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.1),
                                  border: Border.all(
                                    color: isAccent
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    width: isAccent ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrentBeat
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.6),
                                      fontSize: isAccent ? 16 : 14,
                                      fontWeight: isAccent
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),

                    // Subdivision indicators
                    if (subdivision > 1) ...[
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(subdivision * timeSignature, (index) {
                            return AnimatedBuilder(
                              animation: visualBeatController,
                              builder: (context, child) {
                                final isCurrentSubdivision = index == currentBeat;
                                final scale = isCurrentSubdivision
                                    ? 1.0 + visualBeatController.value * 0.5
                                    : 1.0;

                                return Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrentSubdivision
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.3),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        // Floating play/pause button overlay
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isPlaying
                  ? Colors.red
                  : isInitialized
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: isInitialized ? toggleMetronome : null,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        if (!isInitialized)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 