import 'dart:math';
import 'package:flutter/material.dart';

class BlinkingStar extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Offset position;

  const BlinkingStar({
    Key? key,
    this.size = 4.0,
    this.color = Colors.white,
    this.duration = const Duration(seconds: 2),
    required this.position,
  }) : super(key: key);

  @override
  State<BlinkingStar> createState() => _BlinkingStarState();
}

class _BlinkingStarState extends State<BlinkingStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: StarPainter(
              color: widget.color.withOpacity(_animation.value),
            ),
          );
        },
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    final Path path = Path();
    
    // Draw a simple star
    for (int i = 0; i < 5; i++) {
      final double outerX = centerX + radius * cos(2 * pi * i / 5 - pi / 2);
      final double outerY = centerY + radius * sin(2 * pi * i / 5 - pi / 2);
      
      final double innerX = centerX + radius * 0.4 * cos(2 * pi * i / 5 + pi / 10 - pi / 2);
      final double innerY = centerY + radius * 0.4 * sin(2 * pi * i / 5 + pi / 10 - pi / 2);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => color != oldDelegate.color;
}
