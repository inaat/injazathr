import 'package:injazathr/ui/screens/Face/faceRegisterScreen.dart';
import 'package:injazathr/ui/screens/Face/takeAttendance.dart';
import 'package:injazathr/ui/screens/attendanceScreen.dart';
import 'package:injazathr/ui/screens/companyScreen.dart';
import 'package:injazathr/ui/screens/home/homeScreen.dart';
import 'package:injazathr/ui/screens/login/loginScreen.dart';
import 'package:injazathr/ui/screens/privacyPolicyScreen.dart';
import 'package:injazathr/ui/screens/splashScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injazathr/ui/screens/termsAndConditionScreen.dart';

class Routes {
  static const String splash = "splash";
  static const String company = "company";
  static const String map = "map";
  static const String home = "/";
  static const String attendance = "attendance";
  static const String faceRegister = "faceRegister";

  static const String termsAndCondition = "/termsAndCondition";
  static const String privacyPolicy = "/privacyPolicy";

  static const String login = "login";
  static const String takeAttendance = "takeAttendance";

  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? "";
    switch (routeSettings.name) {
      case splash:
        {
          return CupertinoPageRoute(builder: (_) => const SplashScreen());
        }

      case faceRegister:
        {
          return CupertinoPageRoute(builder: (_) => faceRegisterScreen());
        }
      case takeAttendance:
        {
          return CupertinoPageRoute(builder: (_) => TakeAttendance());
        }
      case company:
        {
          return CompanyScreen.route(routeSettings);
        }
      case login:
        {
          return LoginScreen.route(routeSettings);
        }
      case home:
        {
          return HomeScreen.route(routeSettings);
        }
      case attendance:
        {
          return AttendanceScreen.route(routeSettings);
        }

      case termsAndCondition:
        {
          return TermsAndConditionScreen.route(routeSettings);
        }
      case privacyPolicy:
        {
          return PrivacyPolicyScreen.route(routeSettings);
        }
      default:
        {
          return CupertinoPageRoute(builder: (context) => const Scaffold());
        }
    }
  }
}
