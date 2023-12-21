import 'dart:async';

import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    navigateToNextScreen();
    super.initState();
  }

  void navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    // ignore: use_build_context_synchronously
    if (context.read<AuthCubit>().state is Unauthenticated) {
      //  Navigator.of(context).pushReplacementNamed(Routes.login);
      Navigator.of(context).pushReplacementNamed(Routes.company);
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RadialDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              UiUtils.getImagePath("InjazatWhite-min.png"),
              width: 300,
            ),
            // Add some space between the image and text
            Text(
              UiUtils.getTranslatedLabel(context, attendanceAppKey),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
