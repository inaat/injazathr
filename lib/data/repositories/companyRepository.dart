import 'package:injazathr/data/models/company.dart';
import 'package:injazathr/utils/api.dart';

class CompanyRepository {
  Future<List<Company>> fetchSchools() async {
    try {
      final result = await Api.get(url: Api.getSchool, useAuthToken: false);
      print(result);
      return (result['data'] as List)
          .map((company) => Company.fromJson(Map.from(company)))
          .toList();
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
