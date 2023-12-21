import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/SubmitAttendanceCubit.dart';
import 'package:injazathr/cubits/attendanceCubit.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/data/models/attendance.dart';
import 'package:injazathr/data/repositories/attendanceRepository.dart';
import 'package:injazathr/ui/screens/location_dialog.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/ui/widgets/customAppbar.dart';
import 'package:injazathr/ui/widgets/customCircularProgressIndicator.dart';
import 'package:injazathr/ui/widgets/errorContainer.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:android_intent/android_intent.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => AttendanceCubit(AttendanceRepository()),
                ),
                BlocProvider(
                  create: (context) =>
                      SubmitAttendanceCubit(AttendanceRepository()),
                ),
              ],
              child: const AttendanceScreen(),
            ));
  }
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;

  Position? pos;
  bool DebugMode = true;
  bool isLoading = false;
  int remoteModeType = 1;
  Placemark? placeMark;
  late String youLocationServer;
  late String latitudeServer;
  late String longitudeServer;
  late String checkStatus;
  late double latitudeBariKoi;
  late double longitudeBariKoi;
  loc.Location location = loc.Location();

  @override
  void initState() {
    super.initState();
    fetchStatus();
    controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
        animationBehavior: AnimationBehavior.preserve);
    controller.addListener(() {
      setState(() {});
    });
    // Add the listener only once in the initState
    controller.addListener(() {
      if (controller.value.toInt() == 1) {
        handleTap();
        controller.reset();
      }
    });
    _checkGps();
    updatePosition();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleTap() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _checkGps();
    } else {
      if (isLoading == false) {
        print(checkStatus);
        context.read<SubmitAttendanceCubit>().submitAttendance(
              longitude: latitudeBariKoi,
              latitude: latitudeBariKoi,
              location: youLocationServer,
              remoteModeType: remoteModeType,
            );
      } else {
        UiUtils.showBottomToastOverlay(
          context: context,
          errorMessage: "Wait for Location",
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
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
      if (DebugMode) {
        print(youLocationServer);
      }
    }
  }

  //
  void fetchStatus() {
    final user = context.read<AuthCubit>().getUserDetails();

    context.read<AttendanceCubit>().fetchCheckInCheckoutStatus(userId: user.id);
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

  Widget _buildSubmitAttendanceButton() {
    final user_id = context.read<AuthCubit>().getUserDetails().id;
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceFetchSuccess) {
          return BlocConsumer<SubmitAttendanceCubit, SubmitAttendanceState>(
            listener: (context, submitAttendanceState) {
              if (submitAttendanceState is SubmitAttendanceSuccess) {
                context
                    .read<AttendanceCubit>()
                    .fetchCheckInCheckoutStatus(userId: user_id);

                UiUtils.showBottomToastOverlay(
                    context: context,
                    errorMessage: submitAttendanceState.responseMessage,
                    backgroundColor: primaryColor);
              } else if (submitAttendanceState is SubmitAttendanceFailure) {
                UiUtils.showBottomToastOverlay(
                    context: context,
                    errorMessage: UiUtils.getErrorMessageFromErrorCode(
                        context, submitAttendanceState.errorMessage),
                    backgroundColor: Theme.of(context).colorScheme.error);
              }
            },
            builder: (context, submitAttendanceState) {
              return Visibility(
                visible: true,
                child: Center(
                  child: GestureDetector(
                      onVerticalDragCancel: () {
                        controller.reset();
                      },
                      onHorizontalDragCancel: () {
                        controller.reset();
                      },
                      onTapDown: (_) {
                        controller.forward();
                      },
                      onTapUp: (_) {
                        if (controller.status == AnimationStatus.forward) {
                          controller.reverse();
                          controller.value;
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          const SizedBox(
                            height: 175,
                            width: 175,
                            child: CircularProgressIndicator(
                              // strokeWidth: 5,
                              value: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Container(
                            height: 185,
                            width: 185,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
                                    spreadRadius: 3,
                                    blurRadius: 3,
                                    offset: const Offset(0, 3),
                                  )
                                ]),
                            child: submitAttendanceState
                                    is SubmitAttendanceInProgress
                                ? CircularProgressIndicator(
                                    strokeWidth: 10,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 0, 203, 145),
                                    ),
                                  )
                                : CircularProgressIndicator(
                                    strokeWidth: 5,
                                    value: controller.value,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      checkStatus == "Check In"
                                          ? primaryColor
                                          : const Color(0xFFD83675),
                                    ),
                                  ),
                          ),
                          ClipOval(
                            child: Material(
                                child: Container(
                              height: 170,
                              width: 170,
                              decoration: checkStatus == "Check Out"
                                  ? BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            //     ? const Color(0xFF4D4AB6)
                                            // : const Color(0xFFD83675)),
                                            Color(0xFFE8356C),
                                            primaryColor,
                                          ],
                                          begin: FractionalOffset(1.0, 0.0),
                                          end: FractionalOffset(0.0, 3.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    )
                                  : BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            primaryColor,
                                            Color(0xFF00CCFF)
                                          ],
                                          begin: FractionalOffset(1.0, 0.0),
                                          end: FractionalOffset(0.0, 3.0),
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Image.asset(
                                        "assets/images/tap_figer.png",
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        checkStatus ?? "Check In",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          )
                        ],
                      )),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildShimmer() {
    return Center(
        child: ListView(
      children: [
        Column(children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8E8),
            highlightColor: Colors.white,
            child: Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(
                      0), // radius of 10// green as background color
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8E8),
            highlightColor: Colors.white,
            child: Container(
                height: 14,
                width: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(
                      10), // radius of 10// green as background color
                )),
          ),
          const SizedBox(
            height: 15,
          ),
          Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8E8),
            highlightColor: Colors.white,
            child: Container(
                height: 42,
                width: 230,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(
                      30), // radius of 10// green as background color
                )),
          ),
        ]),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 60,
                    width: 230,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          5), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 24,
                    width: 230,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          10), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
            ]),
        Center(
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE8E8E8),
            highlightColor: Colors.white,
            child: Container(
                height: 184,
                width: 184,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(
                      100), // radius of 10// green as background color
                )),
          ),
        ),
        const SizedBox(
          height: 35,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Column(children: [
            Shimmer.fromColors(
              baseColor: const Color(0xFFE8E8E8),
              highlightColor: Colors.white,
              child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(
                        101), // radius of 10// green as background color
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            Shimmer.fromColors(
              baseColor: const Color(0xFFE8E8E8),
              highlightColor: Colors.white,
              child: Container(
                  height: 14,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(
                        101), // radius of 10// green as background color
                  )),
            ),
            const SizedBox(
              height: 5,
            ),
            Shimmer.fromColors(
              baseColor: const Color(0xFFE8E8E8),
              highlightColor: Colors.white,
              child: Container(
                  height: 14,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(
                        101), // radius of 10// green as background color
                  )),
            ),
          ]),
          Column(
            children: [
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
            ],
          ),
          Column(
            children: [
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Shimmer.fromColors(
                baseColor: const Color(0xFFE8E8E8),
                highlightColor: Colors.white,
                child: Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(
                          101), // radius of 10// green as background color
                    )),
              ),
            ],
          ),
        ]),
      ],
    ));
  }

  Widget _buildStudentContainer() {
    final user = context.read<AuthCubit>().getUserDetails();

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        //
        if (state is AttendanceFetchSuccess) {
          //
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('EEEE , MMMM d , yyyy').format(now);

          checkStatus = context.read<AttendanceCubit>().getCheckStatus();
          return Center(
              child: ListView(
            children: [
              Opacity(
                opacity: 1,

                ///provider.isIPEnabled ?? 1,
                child: Visibility(
                  visible: true,

                  ///provider.isCheckIn ?? true,
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xffB7E3E8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset('assets/images/map_marker_icon.json',
                                  height: 35, width: 35),
                              Expanded(
                                child: SizedBox(
                                  child: Text(
                                    "${isLoading ? "Loading..." : youLocationServer}",
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: const Color(0xFF404A58)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
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
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(("choose_your_remote_mode"),
                          style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 42,
                        child: ToggleSwitch(
                          minWidth: 110.0,
                          borderColor: [
                            primaryColor,
                          ],
                          borderWidth: 3,
                          cornerRadius: 30.0,
                          activeBgColors: const [
                            [Colors.white],
                            [Colors.white]
                          ],
                          activeFgColor: primaryColor,
                          inactiveBgColor: primaryColor,
                          inactiveFgColor: Colors.white,
                          initialLabelIndex:
                              remoteModeType, //provider.remoteModeType,
                          icons: const [
                            FontAwesomeIcons.house,
                            FontAwesomeIcons.building
                          ],
                          totalSwitches: 2,
                          labels: [' ${("home")}', (("office"))],
                          radiusStyle: true,
                          onToggle: (index) {
                            /// RemoteModeType
                            /// 0 ==> Home
                            /// 1 ==> office
                            setState(() {
                              remoteModeType = index!;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Opacity(
                  opacity: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      DigitalClock(
                        is24HourTimeFormat: false,
                        hourDigitDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        minuteDigitDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        secondDigitDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        areaDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        digitAnimationStyle: Curves.easeOutExpo,
                        colonDecoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1),
                            shape: BoxShape.circle),
                        hourMinuteDigitTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                        ),
                        amPmDigitTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        secondDigitTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.nunitoSans(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )),
              _buildSubmitAttendanceButton(),
              const SizedBox(
                height: 35,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(
                  children: [
                    Icon(
                      Icons.watch_later_outlined,
                      color: secondaryColor,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      state.attendance.inTime ?? "--:--",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "check_in",
                      style: TextStyle(fontSize: 12, color: secondaryColor),
                    )
                  ],
                ),
                Column(children: [
                  Icon(
                    Icons.watch_later_outlined,
                    color: secondaryColor,
                  ),
                  Text(
                    state.attendance.outTime ?? "--:--",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "check_out",
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                ]),
                Column(children: [
                  Icon(
                    Icons.history,
                    color: secondaryColor,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    state.attendance.stayTime ?? "--:--",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "working_hr",
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  )
                ]),
              ]),
              const SizedBox(
                height: 70,
              )
            ],
          ));
        }
        if (state is AttendanceFetchFailure) {
          return ErrorContainer(
            errorMessageCode: state.errorMessage,
            onTapRetry: () => fetchStatus(),
          );
        }
        return _buildShimmer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var linearGradient = LinearGradient(
        colors: [primaryColor, primaryColorGradient],
        begin: FractionalOffset(3.0, 0.0),
        end: FractionalOffset(0.0, 1.0),
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp);
    return WillPopScope(
        onWillPop: () {
          // if (context.read<AttendanceCubit>().state is AttendanceFetchSuccess) {
          //   return Future.value(false);
          // }

          //Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(Routes.home);

          return Future.value(true);
        },
        child: Container(
            //decoration: RadialDecoration(),
            child: Center(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              flexibleSpace: Container(
                  decoration: BoxDecoration(gradient: linearGradient)),
              leading: IconButton(
                  color: secondaryColor,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(Routes.home);
                  }),
              title: Text(
                'attendance',
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appBarColor,
                    ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    print("11");
                  },
                  child: Row(
                    children: [
                      Lottie.asset(
                        'assets/images/ic_report_lottie.json',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                _buildStudentContainer(),
              ],
            ),
          ),
        )));
  }
}
