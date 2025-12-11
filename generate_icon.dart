import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Generate 512x512 icon with love heart
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = 512.0;

  // Background circle (dark red)
  final bgPaint = Paint()
    ..color = const Color(0xFF8B0000)
    ..style = PaintingStyle.fill;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2, bgPaint);

  // Yellow border
  final borderPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 24;
  canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 12, borderPaint);

  // Draw heart icon (yellow)
  final heartPaint = Paint()
    ..color = const Color(0xFFFFD700)
    ..style = PaintingStyle.fill;

  final heartPath = Path();
  final centerX = size / 2;
  final centerY = size / 2;
  final heartSize = size * 0.5;

  // Heart shape using bezier curves
  heartPath.moveTo(centerX, centerY + heartSize * 0.3);

  // Left side of heart
  heartPath.cubicTo(
    centerX - heartSize * 0.5,
    centerY - heartSize * 0.1,
    centerX - heartSize * 0.5,
    centerY - heartSize * 0.4,
    centerX,
    centerY - heartSize * 0.2,
  );

  // Right side of heart
  heartPath.cubicTo(
    centerX + heartSize * 0.5,
    centerY - heartSize * 0.4,
    centerX + heartSize * 0.5,
    centerY - heartSize * 0.1,
    centerX,
    centerY + heartSize * 0.3,
  );

  canvas.drawPath(heartPath, heartPaint);

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('assets/icon/app_icon.png');
  await file.create(recursive: true);
  await file.writeAsBytes(pngBytes);

  print('✅ Icon generated successfully at: ${file.path}');
  print('📱 Run: flutter pub get');
  print('📱 Then run: flutter pub run flutter_launcher_icons');
}
