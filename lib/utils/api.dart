import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injazathr/utils/constants.dart';
import 'package:injazathr/utils/errorMessageKeysAndCodes.dart';
import 'package:injazathr/utils/hiveBoxKeys.dart';

class ApiException implements Exception {
  String errorMessage;

  ApiException(this.errorMessage);

  @override
  String toString() {
    return errorMessage;
  }
}

class Api {
  static Map<String, dynamic> headers() {
    final String jwtToken = Hive.box(authBoxKey).get(jwtTokenKey) ?? "";
    print('token is $jwtToken');
    return {"Authorization": "Bearer $jwtToken"};
  }

  //
  //User app apis
  //
  static String school = Hive.box(mainUrlBoxKey).get(mainUrl) ?? "";
  static String getSchool = "${databaseUrl}schools";

  //Api methods
  static String settings = "${databaseUrl}settings";

  static String login = "${school}login";
  static String forgotPassword = "${school}forgot-password";
  static String logout = "${school}logout";
  static String changePassword = "${school}change-password";

  ///static String getCheckInCheckoutStatus = "${school}get-check-in-checkout-status";
  static String getCheckInCheckoutStatus = "${school}get-attendance-status";
  static String submitAttendance = "${school}submit-attendance";

  static Future<Map<String, dynamic>> post({
    required Map<String, dynamic> body,
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
  }) async {
    try {
      final Dio dio = Dio();
      final FormData formData =
          FormData.fromMap(body, ListFormat.multiCompatible);
      print('url is $url and query $queryParameters and $useAuthToken');
      final response = await dio.post(url,
          data: formData,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          options: useAuthToken ? Options(headers: headers()) : null);

      if (response.data['error']) {
        print(response.data);
        throw ApiException(response.data['code'].toString());
      }
      return Map.from(response.data);
    } on DioError catch (e) {
      print(e.error);
      throw ApiException(e.error is SocketException
          ? ErrorMessageKeysAndCode.noInternetCode
          : ErrorMessageKeysAndCode.defaultErrorMessageCode);
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      //print(e.toString());
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    required bool useAuthToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    // print('called');
    try {
      //
      final Dio dio = Dio();
      final response = await dio.get(url,
          queryParameters: queryParameters,
          options: useAuthToken ? Options(headers: headers()) : null);
      //  print('url is $url and query $queryParameters and $useAuthToken');
      if (response.data['error']) {
        print(response.data['error']);
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioError catch (e) {
      print('error is ${e.response}');
      throw ApiException(e.error is SocketException
          ? ErrorMessageKeysAndCode.noInternetCode
          : ErrorMessageKeysAndCode.defaultErrorMessageCode);
    } on ApiException catch (e) {
      print(e.toString());
      throw ApiException(e.errorMessage);
    } catch (e) {
      print(e.toString());
      throw ApiException(ErrorMessageKeysAndCode.defaultErrorMessageKey);
    }
  }
}
