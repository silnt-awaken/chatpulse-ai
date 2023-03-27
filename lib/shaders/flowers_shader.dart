import 'dart:math';

import 'package:chatpulse_ai/styles/colors.dart';
import 'package:flutter/material.dart';

class DetailedFlowerPainter extends CustomPainter {
  final Size screenSize;
  final Color color;
  static const double petalRadius = 120.0;

  DetailedFlowerPainter({required this.screenSize, this.color = accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const numPetals = 5;
    const petalCurvature = 0.3;

    final List<Offset> flowerPositions = [
      const Offset(petalRadius, petalRadius),
      Offset(petalRadius, screenSize.height - petalRadius),
      Offset(screenSize.width - petalRadius, screenSize.height / 2),
    ];

    for (final position in flowerPositions) {
      drawFlower(canvas, paint, position.dx, position.dy, petalRadius,
          numPetals, petalCurvature);
    }
  }

  void drawFlower(Canvas canvas, Paint paint, double x, double y,
      double petalRadius, int numPetals, double petalCurvature) {
    final double petalAngle = (2 * pi) / numPetals;

    for (int i = 0; i < numPetals; i++) {
      final double startAngle = petalAngle * i;
      final double endAngle = startAngle + petalAngle;

      final double controlPointRadius = petalRadius * (1 - petalCurvature);
      final double controlPointAngle = startAngle + petalAngle / 2;

      final double controlPointX =
          x + controlPointRadius * cos(controlPointAngle);
      final double controlPointY =
          y + controlPointRadius * sin(controlPointAngle);

      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(controlPointX, controlPointY,
            x + petalRadius * cos(endAngle), y + petalRadius * sin(endAngle))
        ..lineTo(x, y);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SingleFlowerPainter extends CustomPainter {
  final Size screenSize;
  final Color color;
  static const double petalRadius = 120.0;

  SingleFlowerPainter({required this.screenSize, this.color = accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const numPetals = 5;
    const petalCurvature = 0.3;

    final Offset flowerPosition = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );

    drawFlower(canvas, paint, flowerPosition.dx, flowerPosition.dy, petalRadius,
        numPetals, petalCurvature);
  }

  void drawFlower(Canvas canvas, Paint paint, double x, double y,
      double petalRadius, int numPetals, double petalCurvature) {
    final double petalAngle = (2 * pi) / numPetals;
    for (int i = 0; i < numPetals; i++) {
      final double startAngle = petalAngle * i;
      final double endAngle = startAngle + petalAngle;

      final double controlPointRadius = petalRadius * (1 - petalCurvature);
      final double controlPointAngle = startAngle + petalAngle / 2;

      final double controlPointX =
          x + controlPointRadius * cos(controlPointAngle);
      final double controlPointY =
          y + controlPointRadius * sin(controlPointAngle);

      final path = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(controlPointX, controlPointY,
            x + petalRadius * cos(endAngle), y + petalRadius * sin(endAngle))
        ..lineTo(x, y);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
