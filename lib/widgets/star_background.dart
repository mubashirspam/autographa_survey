import 'dart:math';
import 'package:flutter/material.dart';
import 'blinking_star.dart';

class StarBackground extends StatelessWidget {
  final int starCount;
  final Size screenSize;

  const StarBackground({
    Key? key,
    this.starCount = 100,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final random = Random();
    
    return Container(
      width: screenSize.width,
      height: screenSize.height,
      color: Colors.black87,
      child: Stack(
        children: List.generate(starCount, (index) {
          // Generate random positions for stars
          final x = random.nextDouble() * screenSize.width;
          final y = random.nextDouble() * screenSize.height;
          
          // Randomize star properties
          final size = random.nextDouble() * 5.0 + 2.0; // Size between 2.0 and 7.0
          final duration = Duration(
            milliseconds: random.nextInt(1500) + 500, // Duration between 500ms and 2000ms
          );
          
          // Create a color with slight variations
          final color = Colors.white.withOpacity(0.7 + random.nextDouble() * 0.3);
          
          return BlinkingStar(
            position: Offset(x, y),
            size: size,
            color: color,
            duration: duration,
          );
        }),
      ),
    );
  }
}
