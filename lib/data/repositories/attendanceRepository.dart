import 'dart:ffi';
import 'dart:io';

import 'package:injazathr/data/models/attendance.dart';
import 'package:injazathr/data/models/company.dart';
import 'package:injazathr/utils/api.dart';
import 'package:injazathr/utils/appLanguages.dart';
import 'package:injazathr/utils/deviceuuid.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';

class AttendanceRepository {
  Future<Attendance> getUserCheckInCheckoutStatus({
    required int userId,
  }) async {
    try {
      DateTime now = DateTime.now();

      final result = await Api.get(
          url: Api.getCheckInCheckoutStatus,
          useAuthToken: true,
          queryParameters: {
            "user_id": userId,
            "locale": languageCode,
            "date_time": now
          });

      return Attendance.fromJson(Map.from(result['data']));
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //This method is used to update subject marks by subjectId
  Future<Map<String, dynamic>> submitAttendance(
      {required int remoteModeType,
      required double longitude,
      required double latitude,
      required String location}) async {
    try {
      DateTime now = DateTime.now();
      final info = NetworkInfo();

      final wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66

      final body = {
        "longitude": longitude,
        "latitude": latitude,
        "location": location,
        "date_time": now,
        "locale": languageCode,
        "remoteModeType": remoteModeType,
        "device": Platform.isIOS ? 'ios' : 'android',
        'uuid': await DeviceUUid().getUniqueDeviceId(),
        'wiffi_bssid': wifiBSSID
      };
      print(body);
      final result = await Api.post(
          body: body, url: Api.submitAttendance, useAuthToken: true);

      return {
        'error': result['error'],
        'message': result['message'],
        'distanceError': result['distance']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
