import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RealisticFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final faceWidth = Get.width * 0.85;
    final faceHeight = Get.height * 0.55;
    const borderWidth = 4.0; // Largura da borda externa

    // Desenhar a cabeça oval preenchida
    final outerRect = Rect.fromCenter(
      center: center,
      width: faceWidth,
      height: faceHeight,
    );

    // Desenhar a borda externa
    final outerPath = Path()..addOval(outerRect);

    // Desenhar a borda interna (subtraindo a largura da borda da oval externa)
    final innerRect = Rect.fromCenter(
      center: center,
      width: faceWidth - borderWidth * 2,
      height: faceHeight - borderWidth * 2,
    );
    final innerPath = Path()..addOval(innerRect);

    // Desenhar a diferença entre a borda externa e interna
    final combinedPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
