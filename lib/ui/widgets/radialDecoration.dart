import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:injazathr/ui/styles/colors.dart';

BoxDecoration RadialDecoration() {
  return const BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/images/back.png"),
          fit: BoxFit.fitHeight,
          opacity: .7,
          alignment: Alignment.center));
}
//  HexColor("#011754"),
//         HexColor("#041033"),