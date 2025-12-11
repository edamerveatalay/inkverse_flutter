import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/controllers/profile_controller.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_appbar.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_shape.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final profile = controller.profile.value;

        return Stack(
          children: [
            ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[200]!, Colors.pinkAccent],
                  ),
                ),
              ),
            ),

            Column(
              children: [
                CustomAppBar(showBackButton: true),

                SizedBox(height: 20),

                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.grey),
                ),

                SizedBox(height: 20),

                Text(
                  "User ID: ${profile?.userId}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 8),

                Text(
                  profile?.bio ?? "Bio girilmemiş",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed(AppPages.PROFILE_EDIT);
                  },
                  child: Text("Profili Düzenle"),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
