// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/data/models/hive/face_data.dart';
import 'package:injazathr/data/repositories/attendanceRepository.dart';
import 'package:injazathr/services/camera.service.dart';
import 'package:injazathr/services/ml_service.dart';
import 'package:injazathr/ui/screens/location_dialog.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/ui/widgets/customCircularProgressIndicator.dart';
import 'package:injazathr/ui/widgets/customRoundedButton.dart';
import 'package:injazathr/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:injazathr/utils/deviceuuid.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:lottie/lottie.dart';
import 'package:location/location.dart' as loc;
import 'package:intl/intl.dart';

import '../../../cubits/SubmitAttendanceCubit.dart';

class CheckInScreen extends StatefulWidget {
  CheckInScreen({
    Key? key,
    this.face,
    this.imagePath,
    this.cameraService,
    this.faceDetector,
    this.mlService,
  }) : super(key: key);
  FaceData? face;
  String? imagePath;
  final CameraService? cameraService;
  final FaceDetector? faceDetector;
  final MLService? mlService;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                // BlocProvider(
                //   create: (context) => AttendanceCubit(AttendanceRepository()),
                // ),
                BlocProvider(
                  create: (context) =>
                      SubmitAttendanceCubit(AttendanceRepository()),
                ),
              ],
              child: CheckInScreen(),
            ));
  }
}

class _CheckInScreenState extends State<CheckInScreen> {
  String deviceId = "";
  Position? pos;
  bool DebugMode = true;
  bool isLoading = false;
  int remoteModeType = 1;
  Placemark? placeMark;
  late String youLocationServer;
  late String latitudeServer;
  late String longitudeServer;
  late double latitudeBariKoi;
  late double longitudeBariKoi;
  loc.Location location = loc.Location();
  @override
  void initState() {
    super.initState();
    getUniqueDeviceId();
    _checkGps();
    updatePosition();
  }

  @override
  void dispose() {
    widget.cameraService!.dispose();
    widget.faceDetector!.close();
    widget.mlService!.dispose();

    super.dispose();
  }

  Future<void> getUniqueDeviceId() async {
    // Perform the asynchronous work first
    String uniqueId = await DeviceUUid().getUniqueDeviceId();

    // Update the state synchronously
    setState(() {
      deviceId = uniqueId;
    });
  }

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context, builder: (_) => LocationServiceDisabledDialog());
      }
    }
  }

  /// get address from lat log
  Future<dynamic> updatePosition() async {
    setState(() {
      youLocationServer = "";
      isLoading = true;
    });
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      pos = await _determinePosition();
      List pm = await placemarkFromCoordinates(pos!.latitude, pos!.longitude);
      placeMark = pm[0];
      latitudeServer = pos!.latitude.toString();
      longitudeServer = pos!.longitude.toString();

      latitudeBariKoi = pos!.latitude.toDouble();
      longitudeBariKoi = pos!.longitude.toDouble();
      if (DebugMode) {
        print("latitude : $latitudeServer longitude : $longitudeServer");
      }

      if (DebugMode) {
        print("latitude : $latitudeServer longitude : $longitudeServer");
      }
      String? cityServer = placeMark?.locality;
      String? countryCodeServer = placeMark?.isoCountryCode;
      String? countryServer = placeMark?.country;
      setState(() {
        // youLocationServer =
        //     "${placeMark?.street ?? ""}  ${placeMark?.subLocality ?? ""} ${placeMark?.locality ?? ""} ${placeMark?.postalCode ?? ""}";
        youLocationServer =
            "${pos?.latitude.toString() ?? ""}  ${pos?.longitude.toString() ?? ""} ${placeMark?.locality ?? ""} ${placeMark?.postalCode ?? ""}";

        isLoading = false;
      });
    }
  }

  /// get permission from user and get lat log
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        await Geolocator.openAppSettings();
        await Geolocator.openLocationSettings();
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
      await Geolocator.openAppSettings();
      await Geolocator.openLocationSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy:
          // LocationAccuracy.best //,forceAndroidLocationManager: true
          LocationAccuracy.high,
      // timeLimit: const Duration(seconds: 30)
    );
  }

  void handleTap() async {}

  Widget _buildSubmitButton() {
    String? imagePath = widget.imagePath;

    return BlocProvider(
        create: (context) => SubmitAttendanceCubit(
            AttendanceRepository()), // Provide the cubit instance
        child: BlocConsumer<SubmitAttendanceCubit, SubmitAttendanceState>(
          listener: (context, submitAttendanceState) {
            if (submitAttendanceState is SubmitAttendanceSuccess) {
              if (submitAttendanceState.distanceError.isNotEmpty) {
                UiUtils.showBottomToastOverlay(
                    context: context,
                    errorMessage: submitAttendanceState.distanceError,
                    backgroundColor: Theme.of(context).colorScheme.error);
              } else {
                Navigator.of(context).pushReplacementNamed(Routes.home);

                UiUtils.showBottomToastOverlay(
                    context: context,
                    errorMessage: UiUtils.getTranslatedLabel(
                        context, attendanceSubmittedSuccessfullyKey),
                    backgroundColor: Theme.of(context).colorScheme.onPrimary);

                UiUtils.showBottomToastOverlay(
                    context: context,
                    errorMessage: submitAttendanceState.responseMessage,
                    backgroundColor: primaryColor);
              }
            } else if (submitAttendanceState is SubmitAttendanceFailure) {
              UiUtils.showBottomToastOverlay(
                  context: context,
                  errorMessage: UiUtils.getErrorMessageFromErrorCode(
                      context, submitAttendanceState.errorMessage),
                  backgroundColor: Theme.of(context).colorScheme.error);
            }
          },
          builder: (context, submitAttendanceState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: CustomRoundedButton(
                    onTap: () async {
                      if (submitAttendanceState is SubmitAttendanceInProgress) {
                        return;
                      }
                      bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        _checkGps();
                      } else {
                        if (isLoading == false) {
                          File imageFile = File(imagePath!);

                          List<int> imageBytes = await imageFile.readAsBytes();
                          context
                              .read<SubmitAttendanceCubit>()
                              .submitAttendance(
                                longitude: longitudeBariKoi,
                                latitude: latitudeBariKoi,
                                location: youLocationServer,
                                remoteModeType: remoteModeType,
                                // imageBytes:imageBytes,
                              );
                        } else {
                          UiUtils.showBottomToastOverlay(
                            context: context,
                            errorMessage: "Wait for Location",
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          );
                        }
                      }
                    },
                    elevation: 10.0,
                    height: UiUtils.bottomSheetButtonHeight,
                    widthPercentage: UiUtils.bottomSheetButtonWidthPercentage,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    buttonTitle: UiUtils.getTranslatedLabel(context, submitKey),
                    showBorder: false,
                    child: submitAttendanceState is SubmitAttendanceInProgress
                        ? const CustomCircularProgressIndicator(
                            strokeWidth: 2,
                            widthAndHeight: 20,
                          )
                        : null),
              ),
            );
          },
        ));
  }

  Widget _buildTopProfileContainer(BuildContext context) {
    String? imagePath = widget.imagePath;

    return ScreenTopBackgroundContainer(
      padding: const EdgeInsets.all(0),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Stack(
          children: [
            //Bordered circles
            PositionedDirectional(
              top: MediaQuery.of(context).size.width * (-0.15),
              start: MediaQuery.of(context).size.width * (-0.225),
              child: Container(
                padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1)),
                    shape: BoxShape.circle),
                width: MediaQuery.of(context).size.width * (0.6),
                height: MediaQuery.of(context).size.width * (0.6),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1)),
                      shape: BoxShape.circle),
                ),
              ),
            ),

            //bottom fill circle
            PositionedDirectional(
              bottom: MediaQuery.of(context).size.width * (-0.15),
              end: MediaQuery.of(context).size.width * (-0.15),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.1),
                    shape: BoxShape.circle),
                width: MediaQuery.of(context).size.width * (0.4),
                height: MediaQuery.of(context).size.width * (0.4),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsetsDirectional.only(
                    start: boxConstraints.maxWidth * (0.075),
                    bottom: boxConstraints.maxHeight * (0.2)),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(imagePath!)),
                            fit: BoxFit
                                .cover, // Choose the BoxFit based on your requirement
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2.0,
                              color:
                                  Theme.of(context).scaffoldBackgroundColor)),
                      width: boxConstraints.maxWidth * (0.175),
                      height: boxConstraints.maxWidth * (0.175),
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.05),
                    ),
                    Expanded(
                        child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                  .read<AuthCubit>()
                                  .getUserDetails()
                                  .employeeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                            Text(
                              deviceId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w200,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLocationContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Lottie.asset(
                'assets/images/map_marker_icon.json',
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * (0.05),
            ),
            Expanded(
              child: SizedBox(
                  child: Text(
                "${isLoading ? "Loading..." : youLocationServer}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
            ),
            // Text(
            //   UiUtils.getTranslatedLabel(context, moreKey),
            //   style: TextStyle(
            //       color: Theme.of(context).colorScheme.secondary,
            //       fontWeight: FontWeight.w500,
            //       fontSize: 14.0),
            // ),
            InkWell(
              onTap: () async {
                await updatePosition();
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: primaryColor,
                    child: Center(
                      child: Lottie.asset(
                        'assets/images/Refresh.json',
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    ("refresh"),
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildMoreSettingsContainer(BuildContext context) {
    DateTime now = DateTime.now();
    // Format date with day name, month name, and year
    String formattedDate = DateFormat('EEE d MMMM').format(now);

    // Format time with AM/PM
    String formattedTime = DateFormat('h:mm a').format(now);
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: Icon(
                Icons.punch_clock,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
            Container(
              height: 10, // Adjust the height of the vertical divider as needed
              color:
                  Theme.of(context).colorScheme.secondary, // Set the color here
              width: 1.5, // Adjust the width of the vertical divider as needed
              margin: const EdgeInsets.symmetric(
                  horizontal: 20), // Adjust the margin as needed
            ),
            Text(
              formattedTime,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          leading: IconButton(
            color: secondaryColor,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(Routes.home);
            },
          ),
          centerTitle: true,
          title: Column(children: [
            Text(
              "Confirm Clock In",
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: secondaryColor,
                  ),
            ),
            Text(
              'Clock in and start time',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontSize: 10,
                    color: secondaryColor,
                  ),
            ),
          ]),
        ),
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * (0.075),
                    right: MediaQuery.of(context).size.width * (0.075),
                    bottom: UiUtils.getScrollViewBottomPadding(context),
                    top: UiUtils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            UiUtils.appBarBiggerHeightPercentage)),
                child: Column(
                  children: [
                    _buildLocationContainer(context),
                    _buildMoreSettingsContainer(context),
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Divider(),
                          SizedBox(height: 10),
                          _buildSubmitButton()
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildTopProfileContainer(context),
            )
          ],
        ),
      ),
    );
  }
}
