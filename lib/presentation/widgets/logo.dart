import 'package:flutter/material.dart';

class DeepSeekLogo extends StatelessWidget {
  final double size;
  
  const DeepSeekLogo({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6495ED)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Main circle body
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.2, size.height * 0.25,
      size.width * 0.2, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.2, size.height * 0.55,
      size.width * 0.3, size.height * 0.7,
      size.width * 0.5, size.height * 0.7
    );
    path.cubicTo(
      size.width * 0.7, size.height * 0.7,
      size.width * 0.8, size.height * 0.55,
      size.width * 0.8, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.25,
      size.width * 0.7, size.height * 0.1,
      size.width * 0.5, size.height * 0.1
    );
    
    // Left eye
    path.moveTo(size.width * 0.35, size.height * 0.35);
    path.cubicTo(
      size.width * 0.38, size.height * 0.35,
      size.width * 0.4, size.height * 0.37,
      size.width * 0.4, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.4, size.height * 0.43,
      size.width * 0.38, size.height * 0.45,
      size.width * 0.35, size.height * 0.45
    );
    path.cubicTo(
      size.width * 0.32, size.height * 0.45,
      size.width * 0.3, size.height * 0.43,
      size.width * 0.3, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.3, size.height * 0.37,
      size.width * 0.32, size.height * 0.35,
      size.width * 0.35, size.height * 0.35
    );
    
    // Smile
    path.moveTo(size.width * 0.65, size.height * 0.55);
    path.cubicTo(
      size.width * 0.6, size.height * 0.65,
      size.width * 0.55, size.height * 0.75,
      size.width * 0.5, size.height * 0.75
    );
    path.cubicTo(
      size.width * 0.45, size.height * 0.75,
      size.width * 0.4, size.height * 0.65,
      size.width * 0.35, size.height * 0.55
    );
    path.cubicTo(
      size.width * 0.45, size.height * 0.65,
      size.width * 0.55, size.height * 0.65,
      size.width * 0.65, size.height * 0.55
    );
    
    // Right ear
    path.moveTo(size.width * 0.72, size.height * 0.35);
    path.lineTo(size.width * 0.9, size.height * 0.35);
    path.cubicTo(
      size.width * 0.95, size.height * 0.35,
      size.width * 0.95, size.height * 0.5,
      size.width * 0.9, size.height * 0.5
    );
    path.lineTo(size.width * 0.72, size.height * 0.5);
    path.cubicTo(
      size.width * 0.75, size.height * 0.45,
      size.width * 0.75, size.height * 0.4,
      size.width * 0.72, size.height * 0.35
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
