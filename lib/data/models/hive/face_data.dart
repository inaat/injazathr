import 'dart:typed_data';

import 'package:hive/hive.dart';
part 'face_data.g.dart';
@HiveType(typeId: 1)
class FaceData {
  @HiveField(0)
  Uint8List? facePhotoBytes;

  @HiveField(1)
  List? faceArray;

  @HiveField(2)
  String? id;

  @HiveField(3)
  
  String? name;

  FaceData({this.facePhotoBytes, this.faceArray, this.id, this.name});

  factory FaceData.fromJson(Map<String, dynamic> json) {
    return FaceData(
      facePhotoBytes: _uint8ListFromJson(json['facePhotoBytes']),
      faceArray: json['faceArray'],
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};

    data['facePhotoBytes'] = _uint8ListToJson(facePhotoBytes);
    data['faceArray'] = faceArray;
    data['id'] = id;
    data['name'] = name;

    return data;
  }

  static Uint8List? _uint8ListFromJson(List<int>? list) =>
      list != null ? Uint8List.fromList(list) : null;

  static List<int>? _uint8ListToJson(Uint8List? uint8List) =>
      uint8List?.toList();

  static FaceData addFaceData({
    required Uint8List facePhotoBytes,
    required List faceArray,
    required String id,
    required String name,
  }) {
    return FaceData(
      facePhotoBytes: facePhotoBytes,
      faceArray: faceArray,
      id: id,
      name: name,
    );
  }

  static void deleteFaceData(Box<FaceData> box, String id) {
    box.delete(id);
  }

  static void updateFaceData({
    required Box<FaceData> box,
    required String id,
    Uint8List? facePhotoBytes,
    List? faceArray,
    String? name,
  }) {
    final faceData = box.get(id);
    if (faceData != null) {
      if (facePhotoBytes != null) faceData.facePhotoBytes = facePhotoBytes;
      if (faceArray != null) faceData.faceArray = faceArray;
      if (name != null) faceData.name = name;

      box.put(id, faceData);
    }
  }
}
