import 'package:inkverse_flutter/services/api_client.dart';
import 'package:inkverse_flutter/app/models/profile.dart';

class ProfileApi {
  final ApiClient _apiClient = ApiClient();

  Future<Profile?> getProfile() async {
    final response = await _apiClient.dio.get("/profile/");
    return Profile.fromJson(response.data);
  }

  Future<Profile?> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.dio.put("/profile/", data: data);
    return Profile.fromJson(response.data);
  }
}
//UI → ProfileApi → ApiClient → Dio → Backend
//dio paketini kullanarak HTTP istekleriDio paketini kullanarak HTTP istekleri yaparız. Dio, token’ı interceptor ile her isteğe otomatik ekleyerek büyük kolaylık sağlar. yaparız. dio token da direkt ekleyerek kolaylık sağlar 
