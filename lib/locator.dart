import 'package:get_it/get_it.dart';
import 'package:injazathr/services/camera.service.dart';
import 'package:injazathr/services/face_detector_service.dart';
import 'package:injazathr/services/ml_service.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton<CameraService>(() => CameraService());
  locator.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
  locator.registerLazySingleton<MLService>(() => MLService());
}
