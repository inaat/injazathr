class Attendance {
  Attendance(
      {required this.id,
      required this.checkin,
      required this.checkout,
      required this.inTime,
      required this.outTime,
      required this.stayTime});

  late final int? id;
  late final bool? checkin;
  late final bool? checkout;
  late final String? inTime;
  late final String? outTime;
  late final String? stayTime;

  Attendance.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    checkin = json['checkin'];
    checkout = json['checkout'];
    inTime = json['in_time'];
    outTime = json['out_time'];
    stayTime = json['stayTime'];
  }
}
