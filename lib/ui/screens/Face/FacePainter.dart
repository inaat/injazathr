// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:flutter/material.dart';

// class FacePainter extends CustomPainter {
//   FacePainter({required this.imageSize, required this.face});
//   final Size imageSize;
//   double? scaleX, scaleY;
//   Face? face;
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (face == null) return;

//     Paint paint;

//     if (face!.headEulerAngleY! > 10 || face!.headEulerAngleY! < -10) {
//       paint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 3.0
//         ..color = Colors.red;
//     } else {
//       paint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 3.0
//         ..color = Colors.green;
//     }

//     scaleX = size.width / imageSize.width;
//     scaleY = size.height / imageSize.height;

//     canvas.drawRRect(
//         _scaleRect(
//             rect: face!.boundingBox,
//             imageSize: imageSize,
//             widgetSize: size,
//             scaleX: scaleX ?? 1,
//             scaleY: scaleY ?? 1),
//         paint);
//   }

//   @override
//   bool shouldRepaint(FacePainter oldDelegate) {
//     return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
//   }
// }

// RRect _scaleRect(
//     {required Rect rect,
//     required Size imageSize,
//     required Size widgetSize,
//     double scaleX = 1,
//     double scaleY = 1}) {
//   return RRect.fromLTRBR(
//       (widgetSize.width - rect.left.toDouble() * scaleX),
//       rect.top.toDouble() * scaleY,
//       widgetSize.width - rect.right.toDouble() * scaleX,
//       rect.bottom.toDouble() * scaleY,
//       Radius.circular(10));
// }
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:injazathr/utils/uiUtils.dart';

class FacePainter extends CustomPainter {
  FacePainter(
      {required this.imageSize, required this.face, required this.text});

  final Size imageSize;
  double? scaleX, scaleY;
  Face? face;
  String text;

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;

    Paint paint;

    if (face!.headEulerAngleY! > 10 || face!.headEulerAngleY! < -10) {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.red;
    } else {
      paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.green;
    }

    scaleX = size.width / imageSize.width;
    scaleY = size.height / imageSize.height;

    canvas.drawRRect(
      _scaleRect(
        rect: face!.boundingBox,
        imageSize: imageSize,
        widgetSize: size,
        scaleX: scaleX ?? 1,
        scaleY: scaleY ?? 1,
      ),
      paint,
    );
    // Add text on top
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(
        _scaleX(rect: face!.boundingBox, imageSize: imageSize) * scaleX!,
        _scaleY(rect: face!.boundingBox, imageSize: imageSize) * scaleY! - 20.0,
      ),
    );
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }
}

double _scaleX({required Rect rect, required Size imageSize}) {
  return imageSize.width - rect.right;
}

double _scaleY({required Rect rect, required Size imageSize}) {
  return rect.top;
}

RRect _scaleRect({
  required Rect rect,
  required Size imageSize,
  required Size widgetSize,
  double scaleX = 1,
  double scaleY = 1,
}) {
  return RRect.fromLTRBR(
    (widgetSize.width - rect.left.toDouble() * scaleX),
    rect.top.toDouble() * scaleY,
    widgetSize.width - rect.right.toDouble() * scaleX,
    rect.bottom.toDouble() * scaleY,
    Radius.circular(10),
  );
}
