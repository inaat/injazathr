// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/SubmitAttendanceCubit.dart';
import 'package:injazathr/cubits/attendanceCubit.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/data/models/hive/face_data.dart';
import 'package:injazathr/locator.dart';
import 'package:injazathr/services/camera.service.dart';
import 'package:injazathr/services/face_detector_service.dart';
import 'package:injazathr/services/ml_service.dart';
import 'package:injazathr/ui/screens/Face/FacePainter.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/utils/localdb.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:image/image.dart' as imglib;

import '../../../data/repositories/attendanceRepository.dart';

class faceRegisterScreen extends StatefulWidget {
  @override
  _faceRegisterScreenState createState() => _faceRegisterScreenState();
}

class _faceRegisterScreenState extends State<faceRegisterScreen> {
  String? arrowStatus;
  String messageText = "oh no raise your device keep device in face level";
  String directionText = "Looking Straight";
  Face? faceDetected;
  Size? imageSize;
  bool _detectingFaces = false;

  bool _initializing = false;

  bool _saving = true;
  bool _straight = false;
  bool _up = false;
  bool _left = false;
  bool _right = false;
  bool _down = false;

  int capturedImagesCount = 0;
  int totalImagesToCapture = 10;

  // Service injection
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  final MLService _mlService = locator<MLService>();

  bool _faceDetectionInProgress = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    //_cameraService.cameraController?.stopImageStream(); // Stop the image stream
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _faceDetectorService.initialize();
    setState(() => _initializing = false);

    _frameFaces();
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController?.startImageStream((image) async {
      if (_cameraService.cameraController != null && mounted) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          await _faceDetectorService.detectFacesFromImage(image);

          if (_faceDetectorService.faces.isNotEmpty) {
            setState(() {
              faceDetected = _faceDetectorService.faces[0];
            });
            //print(_cameraService.imagePath);
            if (_saving) {
              _mlService.setCurrentPrediction(image, faceDetected);
              onShot(image);
              setState(() {
                _saving = false;
              });
            }
          } else {
            print('face is null');
            setState(() {
              faceDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          print('Error _faceDetectorService face => $e');
          _detectingFaces = false;
        }
      }
    });
  }

  saveImage(predictedData, CameraImage image) async {
    final user = context.read<AuthCubit>().getUserDetails();
    final dataImage = _mlService.getFaceImages(image, faceDetected!);
    final encodedImage = imglib.encodeJpg(dataImage);
    print(encodedImage);
    print('seen');
    var faceData = FaceData(
      facePhotoBytes: encodedImage,
      faceArray: predictedData,
      id: user.id.toString(),
      name: user.employeeName,
    );
    await HiveBoxes.faceDataBox().add(faceData);
    print('FaceData added: $faceData');

    _mlService.setPredictedData([]);
    setState(() {
      _saving = true;
    });
    if (capturedImagesCount == 10) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  Future<bool> onShot(image) async {
    if (faceDetected == null) {
      return false;
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      await Future.delayed(const Duration(milliseconds: 200));

      List predictedData = _mlService.predictedData;
      if (predictedData.isNotEmpty) {
        String headPosition = UiUtils.getHeadPositionText(faceDetected);
        if (headPosition == 'straight' && !_straight) {
          print('$headPosition$capturedImagesCount');

          saveImage(predictedData, image);

          _mlService.setPredictedData([]);
          setState(() => capturedImagesCount++);
          if (capturedImagesCount == 2) {
            setState(() {
              _straight = true;
              arrowStatus = "right";
              directionText = "Now Looking Right ";
            });
          }
        } else if (headPosition == 'right' && !_right && _straight) {
          print('$headPosition$capturedImagesCount');
          saveImage(predictedData, image);

          _mlService.setPredictedData([]);
          setState(() => capturedImagesCount++);

          if (capturedImagesCount == 4) {
            setState(() {
              _right = true;
              arrowStatus = "left";
              directionText = "Now Looking Left ";
            });
          }
        } else if (headPosition == 'left' && !_left && _right && _straight) {
          print('$headPosition$capturedImagesCount');
          saveImage(predictedData, image);
          _mlService.setPredictedData([]);

          setState(() => capturedImagesCount++);

          if (capturedImagesCount == 6) {
            setState(() {
              _left = true;
              arrowStatus = "up";
              directionText = "Now Looking Up ";
            });
          }
        } else if (headPosition == 'up' &&
            !_up &&
            _right &&
            _left &&
            _straight) {
          print('$headPosition$capturedImagesCount');
          saveImage(predictedData, image);

          _mlService.setPredictedData([]);
          setState(() => capturedImagesCount++);

          if (capturedImagesCount == 8) {
            setState(() {
              _up = true;
              arrowStatus = "down";
              directionText = "Now Looking Down ";
            });
          }
        } else if (headPosition == 'down' &&
            !_down &&
            _up &&
            _right &&
            _left &&
            _straight) {
          print('$headPosition$capturedImagesCount');
          saveImage(predictedData, image);

          _mlService.setPredictedData([]);
          setState(() => capturedImagesCount++);

          if (capturedImagesCount == 10) setState(() => _down = true);
        }
      }
      setState(() {
        _saving = true;
      });
      return true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_initializing == false ||
        !_cameraService.cameraController!.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        print("App is in resumed");
        // _cameraService.initialize();
        // _mlService.initialize();
        // _faceDetectorService.initialize();
        break;
      case AppLifecycleState.inactive:
        print("App is in inactive - no need to do anything");
        break;
      case AppLifecycleState.paused:
        print("App is in paused - dispose Camera Controller and ImageStream");
        if (_initializing) {
          // _cameraService.cameraController?.stopImageStream();
          // _cameraService.dispose();
          // _mlService.dispose();
          // _faceDetectorService.dispose();
        }
        break;
      case AppLifecycleState.detached:
        print("App is in detached");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (_initializing) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      final size = MediaQuery.of(context).size;
      final deviceRatio = size.width / size.height;

      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            color: secondaryColor,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Routes.home);
            },
          ),
          title: Text(
            directionText,
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appBarColor,
                ),
          ),
        ),
        body: Container(
            color: Colors.black,
            child: Stack(fit: StackFit.expand, children: [
              Center(
                child: CameraPreview(_cameraService.cameraController!),
              ),
              CustomPaint(
                painter: FacePainter(
                  face: faceDetected,
                  imageSize: imageSize!,
                  text: "",
                ),
              ),
              _buildOverlay(),
              Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          messageText,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          directionText,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ))
            ])),
      );
    }
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        CustomPaint(
          painter: OverlayPainter(
              screenWidth: MediaQuery.of(context).size.width,
              screenHeight: MediaQuery.of(context).size.height,
              progress: capturedImagesCount / totalImagesToCapture,
              arrowStatus: arrowStatus),
        ),
      ],
    );
  }
}

class OverlayPainter extends CustomPainter {
  final double screenWidth;
  final double screenHeight;
  final double progress;
  String? arrowStatus; // Progress value between 0 and 1

  OverlayPainter({
    required this.screenWidth,
    required this.screenHeight,
    required this.progress,
    required this.arrowStatus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = screenWidth * 0.35;
    final strokeWidth = 5.0;
    final center = Offset(screenWidth / 2, screenHeight / 2.5);

    _drawCircleOverlay(canvas, radius, center, strokeWidth);
    _drawCircularProgressBar(canvas, radius, center, strokeWidth);
    _drawArrows(canvas, radius, center);
  }

  void _drawCircleOverlay(
      Canvas canvas, double radius, Offset center, double strokeWidth) {
    final circlePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(screenWidth / 2, screenHeight / 2.5),
        radius: radius,
      ));

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight));
    final overlayPath =
        Path.combine(PathOperation.difference, outerPath, circlePath);

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(overlayPath, paint);
    canvas.drawCircle(
      Offset(screenWidth / 2, screenHeight / 2.5),
      radius,
      borderPaint,
    );
  }

  void _drawCircularProgressBar(
      Canvas canvas, double radius, Offset center, double strokeWidth) {
    final progressRadius = radius - strokeWidth + 10; // Adjust for border
    final progressPath = Path()
      ..addArc(
        Rect.fromCircle(
          center: center,
          radius: progressRadius,
        ),
        -0.5 * pi,
        2 * pi * progress,
      );

    final progressPaint = Paint()
      ..color = Colors.blue // Customize progress bar color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(progressPath, progressPaint);
  }

  void _drawArrows(Canvas canvas, double radius, Offset center) {
    final arrowLength = radius * 0.8;

    // Draw arrows in different directions
    if (arrowStatus == "right") {
      _drawArrow(canvas, center, radius, 0, arrowLength);
    } // right
    if (arrowStatus == "left") {
      _drawArrow(canvas, center, radius, pi, arrowLength); // left
    }
    if (arrowStatus == "down") {
      _drawArrow(canvas, center, radius, 0.5 * pi, arrowLength); // Right
    }
    if (arrowStatus == "up") {
      _drawArrow(canvas, center, radius, 1.5 * pi, arrowLength);
    } // up
  }

  void _drawArrow(Canvas canvas, Offset center, double radius, double angle,
      double length) {
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final arrowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
          center.dx + length * cos(angle), center.dy + length * sin(angle));

    final double arrowHeadSize = length * 0.15;
    final double arrowHeadAngle = 45.0 * pi / 180.0;

    arrowPath.lineTo(
        center.dx +
            length * cos(angle) -
            arrowHeadSize * cos(angle - arrowHeadAngle),
        center.dy +
            length * sin(angle) -
            arrowHeadSize * sin(angle - arrowHeadAngle));
    arrowPath.moveTo(
        center.dx + length * cos(angle),
        center.dy +
            length *
                sin(angle)); // Move to the tip of the arrow before drawing the other side
    arrowPath.lineTo(
        center.dx +
            length * cos(angle) -
            arrowHeadSize * cos(angle + arrowHeadAngle),
        center.dy +
            length * sin(angle) -
            arrowHeadSize * sin(angle + arrowHeadAngle));
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
