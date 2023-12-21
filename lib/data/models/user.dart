import 'dart:convert';

class User {
  User({
    required this.id,
    required this.fcmId,
    required this.employeeName,
    required this.mobileNo,
    required this.iqamaNo,
    required this.employeeNo,
    required this.image,
    required this.gender,
    required this.email,
    required this.preferredLang,
    required this.age,
    required this.civilStatus,
    required this.nationality,
    required this.placeOfBirth,
    required this.passportNo,
    required this.position,
    required this.positionIqamaPassport,
    required this.department,
    required this.section,
    required this.localCountry,
    required this.homeCountry,
    required this.currentAddress,
    required this.permanentAddress,
    required this.modelData,
  });

  late final int id;
  late final String fcmId;
  late final String employeeName;
  late final String mobileNo;
  late final String iqamaNo;
  late final String employeeNo;
  late final String image;
  late final String gender;
  late final String email;
  late final String preferredLang;
  late final String age;
  late final String civilStatus;
  late final String nationality;
  late final String placeOfBirth;
  late final String passportNo;
  late final String position;
  late final String positionIqamaPassport;
  late final String department;
  late final String section;
  late final String localCountry;
  late final String homeCountry;
  late final String currentAddress;
  late final String permanentAddress;
  List? modelData;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    fcmId = json['employee_name'] ?? "";
    employeeName = json['employee_name'] ?? "";
    mobileNo = json["mobile_no "] ?? "";
    iqamaNo = json["iqama_no"] ?? "";
    employeeNo = json["employee_no"] ?? "";
    image = json["image"] ?? "";
    gender = json["gender"] ?? "";
    email = json['email'] ?? "";
    preferredLang = json['preferred_lang'] ?? "";
    age = json['age'] ?? "";
    civilStatus = json['civil_status'] ?? "";
    nationality = json['nationality '] ?? "";
    placeOfBirth = json['place_of_birth'] ?? "";
    passportNo = json['passport_no'] ?? "";
    position = json['position'] ?? "";
    positionIqamaPassport = json['position_iqama_passport'] ?? "";
    department = json['department '] ?? "";
    section = json['section'] ?? "";
    localCountry = json['localCountry'] ?? "";
    homeCountry = json['homeCountry '] ?? "";
    currentAddress = json['current_address'] ?? "";
    permanentAddress = json['permanenta_address'] ?? "";
    // Check if 'model_data' is a String before decoding
    if (json['model_data'] is String) {
      modelData = jsonDecode(json['model_data'] ?? "[]");
    } else {
      // Handle the case where 'model_data' is not a String
      modelData = [];
    }
  }
  String getFullName() {
    return employeeName;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};

    // _data['user'] = {"id": teacherId, "qualification": qualification};
    _data['id'] = id;
    _data['fcmId'] = fcmId;
    _data['employee_name'] = employeeName;
    _data["mobile_no "] = mobileNo;
    _data["iqama_no"] = iqamaNo;
    _data["employee_no"] = employeeNo;
    _data["image"] = image;
    _data["gender"] = gender;
    _data['email'] = email;
    _data['preferred_lang'] = preferredLang;
    _data['age'] = age;
    _data['civil_status'] = civilStatus;
    _data['nationality '] = nationality;
    _data['place_of_birth'] = placeOfBirth;
    _data['passport_no'] = passportNo;
    _data['position'] = position;
    _data['position_iqama_passport'] = positionIqamaPassport;
    _data['department '] = department;
    _data['section'] = section;
    _data['local_country'] = localCountry;
    _data['home_country '] = homeCountry;
    _data['current_address'] = currentAddress;
    _data['permanent_address'] = permanentAddress;
    _data['model_data'] = jsonEncode(modelData);

    return _data;
  }
}
