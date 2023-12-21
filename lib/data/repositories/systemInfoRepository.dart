import 'package:injazathr/utils/api.dart';

class SystemRepository {
 
  Future<dynamic> fetchSettings({required String type}) async {
    try {
      final result = await Api.get(
          queryParameters: {"type": type},
          url: Api.settings,
          useAuthToken: false);

      return result['data'];
    } catch (e) {
      print(e.toString());
      throw ApiException(e.toString());
    }
  }

  
}
