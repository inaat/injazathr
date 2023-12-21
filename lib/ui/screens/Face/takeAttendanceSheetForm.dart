import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:injazathr/data/models/hive/face_data.dart';
import 'package:injazathr/locator.dart';
import 'package:injazathr/services/camera.service.dart';
import 'package:injazathr/ui/screens/Face/app_button.dart';

class TakeAttendanceSheet extends StatelessWidget {
  TakeAttendanceSheet({Key? key, required this.face, this.imagePath})
      : super(key: key);

  final FaceData face;
  final String? imagePath;
  final _passwordController = TextEditingController();
  final _cameraService = locator<CameraService>();

  Future _signIn(context, face) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(content: Text((face.name.toString())));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Welcome back, ' + face.name.toString() + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Column(
              children: [
                if (imagePath != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(imagePath!)),
                      ),
                    ),
                    margin: EdgeInsets.all(20),
                    width: 50,
                    height: 50,
                  ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                AppButton(
                  text: 'Check In',
                  onPressed: () async {
                    _signIn(context, face);
                  },
                  icon: Icon(
                    Icons.login,
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: 112,
                  width: 112,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[Color(0xffD7E5CA), Color(0xffF9F3CC)]),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(35.0)),
                    border: Border.fromBorderSide(BorderSide()),
                  ),
                  child: face.facePhotoBytes != null
                      ? Image.memory(face.facePhotoBytes!)
                      : const Icon(Icons.person_add_alt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
