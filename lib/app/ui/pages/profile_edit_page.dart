import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/controllers/profile_controller.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_appbar.dart';
import 'package:inkverse_flutter/app/ui/widgets/text_form_field.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final ProfileController controller = Get.find<ProfileController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final p = controller.profile.value;
    if (p != null) {
      nameController.text = p.name ?? "";
      bioController.text = p.bio ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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

              SizedBox(height: 20),

              // Profil fotoğrafı (şimdilik ikon)
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),

              SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  hint: "İsim",
                  icon: Icons.person,
                  textEditingController: nameController,
                  keyboardType: TextInputType.text,
                ),
              ),

              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  hint: "Bio",
                  icon: Icons.info_outline,
                  textEditingController: bioController,
                  keyboardType: TextInputType.text,
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
                    "name": nameController.text.trim(),
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
