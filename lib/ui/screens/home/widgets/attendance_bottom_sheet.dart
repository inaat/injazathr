
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:injazathr/ui/screens/home/widgets/buttonborder.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:provider/provider.dart';

class AttedanceBottomSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AttendanceBottomSheetState();
}

class AttendanceBottomSheetState extends State<AttedanceBottomSheet> {
  bool isEnabled = true;
  bool isLoading = false;

  void onCheckOut() async {
   ;
   
    
  }

  void onCheckIn() async {
  
    
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return !isLoading;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Check in/out',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.white,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 5),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: HexColor("#036eb7"),
                                shape: ButtonBorder()),
                            onPressed: () async {
                              isEnabled ? onCheckIn() : null;
                              isEnabled = false;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const Text(
                                'Check in',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: HexColor("#036eb7"),
                                shape: ButtonBorder()),
                            onPressed: () {
                              isEnabled ? onCheckOut() : null;
                              isEnabled = false;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: const Text(
                                'Check out',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
