import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:injazathr/app/appLocalization.dart';
import 'package:injazathr/ui/widgets/bottomToastOverlayContainer.dart';
import 'package:injazathr/utils/constants.dart';
import 'package:injazathr/utils/errorMessageKeysAndCodes.dart';

import 'labelKeys.dart';

class UiUtils {
  //This extra padding will add to MediaQuery.of(context).padding.top in orderto give same top padding in every screen

  static double screenContentTopPadding = 15.0;
  static double screenContentHorizontalPadding = 25.0;
  static double screenTitleFontSize = 18.0;
  static double screenSubTitleFontSize = 14.0;
  static double textFieldFontSize = 15.0;

  static double screenContentHorizontalPaddingPercentage = 0.075;

  //

  static double bottomSheetButtonHeight = 45.0;
  static double bottomSheetButtonWidthPercentage = 0.625;

  static double extraScreenContentTopPaddingForScrolling = 0.0275;
  static double appBarSmallerHeightPercentage = 0.15;

  static double appBarMediumtHeightPercentage = 0.175;

  static double appBarBiggerHeightPercentage = 0.225;

  static double bottomNavigationHeightPercentage = 0.075;
  static double bottomNavigationBottomMargin = 25;

  static double bottomSheetHorizontalContentPadding = 20;

  static double subjectFirstLetterFontSize = 20;

  static double shimmerLoadingContainerDefaultHeight = 7;

  static int defaultShimmerLoadingContentCount = 4;

  static double appBarContentTopPadding = 25.0;
  static double bottomSheetTopRadius = 20.0;
  static Duration tabBackgroundContainerAnimationDuration =
      Duration(milliseconds: 300);
  static Curve tabBackgroundContainerAnimationCurve = Curves.easeInOut;
  static double screenContentHorizontalPaddingInPercentage = 0.075;

  static String getImagePath(String imageName) {
    return "assets/images/$imageName";
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1
        ? Locale(result.first)
        : Locale(result.first, result.last);
  }

  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static String getTranslatedLabel(BuildContext context, String labelKey) {
    return (AppLocalization.of(context)!.getTranslatedValues(labelKey) ??
            labelKey)
        .trim();
  }

  static String getErrorMessageFromErrorCode(
      BuildContext context, String errorCode) {
    return UiUtils.getTranslatedLabel(
        context, ErrorMessageKeysAndCode.getErrorMessageKeyFromCode(errorCode));
  }

  static Future<void> showBottomToastOverlay(
      {required BuildContext context,
      required String errorMessage,
      required Color backgroundColor}) async {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => BottomToastOverlayContainer(
        backgroundColor: backgroundColor,
        errorMessage: errorMessage,
      ),
    );

    overlayState.insert(overlayEntry);
    await Future.delayed(errorMessageDisplayDuration);
    overlayEntry.remove();
  }

  static Future<dynamic> showBottomSheet(
      {required Widget child,
      required BuildContext context,
      bool? enableDrag}) async {
    final result = await showModalBottomSheet(
        enableDrag: enableDrag ?? false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(bottomSheetTopRadius),
                topRight: Radius.circular(bottomSheetTopRadius))),
        context: context,
        builder: (_) => child);

    return result;
  }

  static String getBackButtonPath(BuildContext context) {
    return Directionality.of(context).name == TextDirection.rtl.name
        ? getImagePath("rtl_back_icon.svg")
        : getImagePath("back_icon.svg");
  }

  //to give bottom scroll padding in screen where
  //bottom navigation bar is displayed
  static double getScrollViewBottomPadding(BuildContext context) {
    return MediaQuery.of(context).size.height *
            (UiUtils.bottomNavigationHeightPercentage) +
        UiUtils.bottomNavigationBottomMargin * (1.5);
  }

  //to give top scroll padding to screen content
  //
  static double getScrollViewTopPadding(
      {required BuildContext context, required double appBarHeightPercentage}) {
    return MediaQuery.of(context).size.height *
        (appBarHeightPercentage + extraScreenContentTopPaddingForScrolling);
  }

  //Date format is DD-MM-YYYY
  static String formatStringDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  static String formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  static String getHeadPositionText(face) {
    //getBackCameraHeadPositionText
    if (face == null) {
      return 'Head Position: Unknown';
    }

    double headEulerAngleY = face!.headEulerAngleY ?? 0.0;
    double headEulerAngleX = face!.headEulerAngleX ?? 0.0;

    if (headEulerAngleY > 10) {
      return 'left';
    } else if (headEulerAngleY < -10) {
      return 'right';
    } else if (headEulerAngleY > -10 && headEulerAngleY < 10) {
      if (headEulerAngleX > 10) {
        return 'up';
      } else if (headEulerAngleX < -10) {
        return 'down';
      } else {
        return 'straight';
      }
    } else {
      return 'Head Position: Unknown';
    }
  }
}


