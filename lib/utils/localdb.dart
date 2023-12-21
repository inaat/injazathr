import 'package:hive/hive.dart';
import 'package:injazathr/data/models/hive/face_data.dart';

class HiveBoxes {
  static const faceData = "faceData";

  static Box faceDataBox() => Hive.box(faceData);

  static initialize() async {
    initializeAdapters();

    await Hive.openBox(faceData);
  }

  static initializeAdapters() {
    Hive.registerAdapter(FaceDataAdapter());
  }

  static clearAllData() {
    faceDataBox().clear();
  }
}
