import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injazathr/data/models/attendance.dart';
import 'package:injazathr/data/repositories/attendanceRepository.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceFetchInProgress extends AttendanceState {}

class AttendanceFetchSuccess extends AttendanceState {
  final Attendance attendance;

  AttendanceFetchSuccess({required this.attendance});
}

class AttendanceFetchFailure extends AttendanceState {
  final String errorMessage;

  AttendanceFetchFailure(this.errorMessage);
}

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _attendanceRepository;

  AttendanceCubit(this._attendanceRepository) : super(AttendanceInitial());

  void updateState(AttendanceState updatedState) {
    emit(updatedState);
  }

  void fetchCheckInCheckoutStatus({required int userId}) async {
    emit(AttendanceFetchInProgress());
    try {
      emit(
        AttendanceFetchSuccess(
          attendance: (await _attendanceRepository.getUserCheckInCheckoutStatus(
              userId: userId)),
        ),
      );
    } catch (e) {
      emit(AttendanceFetchFailure(e.toString()));
    }
  }

  Attendance getAttendanceStatus() {
    if (state is AttendanceFetchSuccess) {
      return (state as AttendanceFetchSuccess).attendance;
    }
    return Attendance.fromJson({});
  }

  String getCheckStatus() {
    if (state is AttendanceFetchSuccess) {
      if (getAttendanceStatus().checkin == false &&
          getAttendanceStatus().checkout == false) {
        return "Check In";
      } else if (getAttendanceStatus().checkin == true &&
          getAttendanceStatus().checkout == true) {
        return "Check In";
      } else if (getAttendanceStatus().checkin == true &&
          getAttendanceStatus().checkout == false) {
        return "Check Out";
      }
    }
    return "";
  }
}
