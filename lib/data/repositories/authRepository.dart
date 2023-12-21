import 'dart:io';

import 'package:injazathr/data/models/user.dart';
import 'package:injazathr/utils/api.dart';
import 'package:injazathr/utils/appLanguages.dart';
import 'package:injazathr/utils/deviceuuid.dart';
import 'package:injazathr/utils/hiveBoxKeys.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthRepository {
  //LocalDataSource
  bool getIsLogIn() {
    return Hive.box(authBoxKey).get(isLogInKey) ?? false;
  }

  Future<void> setIsLogIn(bool value) async {
    return Hive.box(authBoxKey).put(isLogInKey, value);
  }

  User getUserDetails() {
    return User.fromJson(
        Map.from((Hive.box(authBoxKey).get(teacherDetailsKey) ?? {})));
  }

  Future<void> setUserDetails(User user) async {
    return Hive.box(authBoxKey).put(teacherDetailsKey, user.toJson());
  }

  String getJwtToken() {
    return Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
  }

  Future<void> setJwtToken(String value) async {
    return Hive.box(authBoxKey).put(jwtTokenKey, value);
  }

  Future<void> SetMainUrlBoxKey(String value) async {
    return Hive.box(mainUrlBoxKey).put(mainUrl, value);
  }

  Future<void> signOutUser() async {
    try {
      Api.post(body: {}, url: Api.logout, useAuthToken: true);
    } catch (e) {}
    setIsLogIn(false);
    setJwtToken("");
    SetMainUrlBoxKey("");
    setUserDetails(User.fromJson({}));
  }

  //RemoteDataSource
  Future<Map<String, dynamic>> signInUser(
      {required String mobileNo, required String password}) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final body = {
        "locale": languageCode,
        "password": password,
        "mobile_no": mobileNo,
        "fcm_id": fcmToken,
        'device_type': Platform.isIOS ? 'ios' : 'android',
        'uuid': await DeviceUUid().getUniqueDeviceId(),
      };

      final result =
          await Api.post(body: body, url: Api.login, useAuthToken: false);
      print(result);
      return {
        "jwtToken": result['token'],
        "user": User.fromJson(Map.from(result['data']))
      };
    } catch (e) {
      print(e.toString());
      throw ApiException(e.toString());
    }
  }

  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      required String newConfirmedPassword}) async {
    try {
      final body = {
        "current_password": currentPassword,
        "new_password": newPassword,
        "new_confirm_password": newConfirmedPassword
      };
      await Api.post(body: body, url: Api.changePassword, useAuthToken: true);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      final body = {"email": email};
      await Api.post(body: body, url: Api.forgotPassword, useAuthToken: false);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
