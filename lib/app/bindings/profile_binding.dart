import 'package:get/get.dart';
import 'package:inkverse_flutter/app/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProfileController());
  }
}
