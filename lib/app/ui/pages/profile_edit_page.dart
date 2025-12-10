import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/controllers/profile_controller.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_appbar.dart';
import 'package:inkverse_flutter/app/ui/widgets/text_form_field.dart';

class ProfileEditPage extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Sayfa açıldığında mevcut bio’yu doldur
    if (controller.profile.value?.bio != null) {
      bioController.text = controller.profile.value!.bio!;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[200]!, Colors.pinkAccent],
              ),
            ),
          ),

          Column(
            children: [
              CustomAppBar(showBackButton: true),

              SizedBox(height: 20),

              Text(
                "Profili Düzenle",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  hint: "Bio",
                  textEditingController: bioController,
                  keyboardType: TextInputType.text,
                  icon: Icons.info_outline,
                ),
              ),

              SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  await controller.updateProfile({
                    "bio": bioController.text.trim(),
                  });

                  Get.back();
                },
                child: Text("Kaydet", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
