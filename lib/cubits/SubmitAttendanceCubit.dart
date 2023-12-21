import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injazathr/data/models/attendance.dart';
import 'package:injazathr/data/repositories/attendanceRepository.dart';

abstract class SubmitAttendanceState {}

class SubmitAttendanceInitial extends SubmitAttendanceState {}

class SubmitAttendanceInProgress extends SubmitAttendanceState {}

class SubmitAttendanceSuccess extends SubmitAttendanceState {
  final String responseMessage;
  final String distanceError;

  SubmitAttendanceSuccess(this.responseMessage, this.distanceError);
}

class SubmitAttendanceFailure extends SubmitAttendanceState {
  final String errorMessage;

  SubmitAttendanceFailure(this.errorMessage);
}

class SubmitAttendanceCubit extends Cubit<SubmitAttendanceState> {
  final AttendanceRepository _attendanceRepository;

  SubmitAttendanceCubit(this._attendanceRepository)
      : super(SubmitAttendanceInitial());

  void submitAttendance(
      {required int remoteModeType,
      required double longitude,
      required double latitude,
      required String location}) async {
    emit(SubmitAttendanceInProgress());
    try {
      final response = await _attendanceRepository.submitAttendance(
          remoteModeType: 1,
          latitude: latitude,
          longitude: longitude,
          location: location);
      emit(SubmitAttendanceSuccess(
          response['message'], response['distanceError']));
    } catch (e) {
      emit(SubmitAttendanceFailure(e.toString()));
    }
  }
}
