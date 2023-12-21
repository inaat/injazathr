import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/data/models/hive/face_data.dart';
import 'package:injazathr/locator.dart';
import 'package:injazathr/services/camera.service.dart';
import 'package:injazathr/services/face_detector_service.dart';
import 'package:injazathr/services/ml_service.dart';
import 'package:injazathr/ui/screens/Face/FacePainter.dart';
import 'package:injazathr/ui/screens/Face/auth_button.dart';
import 'package:injazathr/ui/screens/Face/camera_detection_preview.dart';
import 'package:injazathr/ui/screens/Face/camera_header.dart';
import 'package:injazathr/ui/screens/Face/checkIn.dart';
import 'package:injazathr/ui/screens/Face/takeAttendanceSheetForm.dart';
import 'package:injazathr/ui/screens/Face/single_picture.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/utils/uiUtils.dart';

class TakeAttendance extends StatefulWidget {
  const TakeAttendance({Key? key}) : super(key: key);

  @override
  TakeAttendanceState createState() => TakeAttendanceState();
}

class TakeAttendanceState extends State<TakeAttendance> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;
  bool processing = false;

  // service injection

  CameraService _cameraService = locator<CameraService>();
  FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
  MLService _mlService = locator<MLService>();
  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

 

  Future _start() async {
    if (mounted) {
      setState(() => _isInitializing = true);
      await _cameraService.initialize();
      await _mlService.initialize();
      _faceDetectorService.initialize();
      setState(() => _isInitializing = false);

      _frameFaces();
    }
  }

  _frameFaces() async {
    _cameraService.cameraController!
        .startImageStream((CameraImage image) async {
      if (processing || !mounted) return; // Check if widget is still mounted
      processing = true;
      //await _predictFacesFromImage(image: image, context: context);

      await _predictFacesFromImage(
        image: image,
        scaffoldKey: scaffoldKey,
      );
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({
    @required CameraImage? image,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) async {
    assert(image != null, 'Image is null');

    await _faceDetectorService.detectFacesFromImage(image!);
    print('Before' + _faceDetectorService.faceDetected.toString());
    if (_faceDetectorService.faceDetected) {
      _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
      final Rect boundingBox = _faceDetectorService.faces[0].boundingBox;
      print('Rect' + boundingBox.toString());
      print('leftEyeOpenProbability' +
          _faceDetectorService.faces[0].leftEyeOpenProbability.toString());
      print('rightEyeOpenProbability' +
          _faceDetectorService.faces[0].rightEyeOpenProbability.toString());

      FaceData? face = await _mlService.predict();

      if (face != null) {
        await _cameraService.takePicture();
        _mlService.setPredictedData([]);
        _faceDetectorService.setFaceDetectedClear(false);

        String? _imagePath = _cameraService.imagePath;
        print(face.name);
        print((await _mlService.predict().toString()));
        setState(() => face = null);

        if (mounted) {
          Navigator.push(
            scaffoldKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => CheckInScreen(
                imagePath: _imagePath,
                face: face,
              ),
            ),
          );
        }
      }
    }
  }

  _onBackPressed() {
    // if (Navigator.of(context).canPop()) {
    //   Navigator.of(context).pop();
    // } else {
    Navigator.of(context).pushReplacementNamed(Routes.home);
    // }
  }

  Widget getBodyWidget() {
    if (_isInitializing) return Center(child: CircularProgressIndicator());
    if (_isPictureTaken && _cameraService.imagePath != null) {
      return SinglePicture(imagePath: _cameraService.imagePath!);
    }
    final width = MediaQuery.of(context).size.width;
    //return CameraDetectionPreview();
    return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: CameraPreview(_cameraService.cameraController!),
            ),
            if (_faceDetectorService.faceDetected)
              CustomPaint(
                painter: FacePainter(
                  face: _faceDetectorService.faces[0],
                  imageSize: _cameraService.getImageSize(),
                  text: '',
                ),
              ),
            _buildOverlay(),
          ],
        ));
  }

  Widget _buildOverlay() {
    return Stack(
      children: [
        CustomPaint(
            painter: OverlayPainter(
                screenWidth: MediaQuery.of(context).size.width,
                screenHeight: MediaQuery.of(context).size.height)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget header =
        CameraHeader("Face Recognition ", onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();

    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            color: Colors.white,
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Routes.home);
            },
          ),
          title: Text(
            "Face Recognition",
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: appBarColor,
                ),
          ),
        ),
        body: Stack(
          children: [body],
        ));
  }

  signInSheet({String? imagePath, @required FaceData? faces}) => faces == null
      ? Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Text(
            'User not found 😞',
            style: TextStyle(fontSize: 20),
          ),
        )
      : TakeAttendanceSheet(face: faces, imagePath: imagePath);
}

class OverlayPainter extends CustomPainter {
  final double screenWidth;
  final double screenHeight;
  // Progress value between 0 and 1

  OverlayPainter({required this.screenWidth, required this.screenHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = screenWidth * 0.35;
    final strokeWidth = 5.0;
    final center = Offset(screenWidth / 2, screenHeight / 2.5);

    _drawCircleOverlay(canvas, radius, center, strokeWidth);
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
