import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/attendanceCubit.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/ui/screens/Face/checkIn.dart';
import 'package:injazathr/ui/screens/home/widgets/attendance_bottom_sheet.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/ui/widgets/errorContainer.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/localdb.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

import '../../../../data/repositories/attendanceRepository.dart';

class CheckAttendance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CheckAttendanceState();
}

class CheckAttendanceState extends State<CheckAttendance> {
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => CheckAttendance());
  }

  late String checkStatus;

  @override
  void initState() {
    super.initState();
    fetchAttendanceStatus();
  }

  void fetchAttendanceStatus() {
    final user = context.read<AuthCubit>().getUserDetails();

    context.read<AttendanceCubit>().fetchCheckInCheckoutStatus(userId: user.id);
  }

  Widget _buildAttendanceContainer() {
    final user = context.read<AuthCubit>().getUserDetails();

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        //
        if (state is AttendanceFetchSuccess) {
          //
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('EEEE , MMMM d , yyyy').format(now);

          checkStatus = context.read<AttendanceCubit>().getCheckStatus();
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DigitalClock(
                  is24HourTimeFormat: false,
                  hourDigitDecoration: BoxDecoration(color: Colors.transparent),
                  minuteDigitDecoration:
                      BoxDecoration(color: Colors.transparent),
                  secondDigitDecoration:
                      BoxDecoration(color: Colors.transparent),
                  areaDecoration: BoxDecoration(color: Colors.transparent),
                  digitAnimationStyle: Curves.easeOutExpo,
                  colonDecoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1),
                      shape: BoxShape.circle),
                  hourMinuteDigitTextStyle: TextStyle(
                    color: secondaryColor,
                    fontSize: 50,
                  ),
                  amPmDigitTextStyle: TextStyle(
                    color: secondaryColor,
                  ),
                  secondDigitTextStyle: TextStyle(
                    color: secondaryColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                  formattedDate,
                  style: TextStyle(color: secondaryColor),
                )),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(90)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        color: primaryColor,
                        child: Column(
                          children: [
                            IconButton(
                              iconSize: 70,
                              onPressed: () async {
                                final List facesArray =
                                    HiveBoxes.faceDataBox().values.toList();
                                if (facesArray.isEmpty) {
                                  // Navigator.of(context).pushReplacementNamed(
                                  //     Routes.cameraOverlay);
                                  showFaceRegisterDialog(context);
                                } else if (facesArray.length < 9) {
                                  showFaceRegisterDialog(context);
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      Routes.takeAttendance);
                                }

                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) => CheckInScreen()));
                              },
                              icon: SvgPicture.asset(
                                UiUtils.getImagePath(
                                    "face-scan.svg"), // Replace with your SVG file path
                                width: 100,
                                height: 100,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                    child: Text(
                  "Check In | Check Out",
                  style: TextStyle(color: secondaryColor, fontSize: 15),
                )),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                              style: TextStyle(
                                  fontSize: 12, color: secondaryColor),
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
                            style:
                                TextStyle(fontSize: 12, color: secondaryColor),
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
                            style:
                                TextStyle(fontSize: 12, color: secondaryColor),
                          )
                        ]),
                      ]),
                )
              ]);
        }
        if (state is AttendanceFetchFailure) {
          return ErrorContainer(
            errorMessageCode: state.errorMessage,
            onTapRetry: () => fetchAttendanceStatus(),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void showFaceRegisterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                "Missing face data",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0),
              ),
              content: Text(
                "You are required to clock in and out with facial recognition. Take a selfie as your face data now to continue. ",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w300,
                    fontSize: 12.0),
              ),
              actions: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Center the button using alignment
                  alignment: Alignment.center,
                  child: CupertinoButton(
                    child: Text(
                      "Take photo",
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(Routes.faceRegister);
                    },
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final attendanceList = [''];

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE , MMMM d , yyyy').format(now);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: _buildAttendanceContainer(),
    );
  }
}
