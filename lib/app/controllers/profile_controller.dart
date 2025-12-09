import 'package:get/get.dart';
import 'package:inkverse_flutter/app/models/profile.dart';
import 'package:inkverse_flutter/services/profile_api.dart';

class ProfileController extends GetxController {
  final ProfileApi _profileApi = ProfileApi();

  var profile = Rxn<Profile>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final data = await _profileApi.getProfile();
      profile.value = data;
    } catch (e) {
      print("Profil alınırken hata: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      final updated = await _profileApi.updateProfile(data);
      profile.value = updated; // UI otomatik güncellenir
    } catch (e) {
      print("Profil güncellenirken hata: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
