import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_shape.dart';
import 'package:inkverse_flutter/app/ui/widgets/custom_appbar.dart';
import 'package:inkverse_flutter/app/ui/widgets/responsive_ui.dart';
import 'package:inkverse_flutter/app/ui/widgets/text_form_field.dart';
import 'package:inkverse_flutter/services/auth_api.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool checkBoxValue = false;
  late double _height;
  late double _width;
  late double _pixelRatio;
  bool _large = false;
  bool _medium = false;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Opacity(opacity: 0.88, child: CustomAppBar()),
            clipShape(),
            form(),
            acceptTermsTextRow(),
            SizedBox(height: _height / 35),
            button(),
            infoTextRow(),
            socialIconsRow(),
            SizedBox(height: _height / 35),
            backendTestButton(),
          ],
        ),
      ),
    );
  }

  Widget infoTextRow() {
    return Padding(
      padding: EdgeInsets.only(top: _height / 40.0),
      child: Text(
        "Veya sosyal medya ile kayıt ol",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: _large ? 12 : (_medium ? 11 : 10),
        ),
      ),
    );
  }

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.75,
          child: ClipPath(
            clipper: CustomShapeClipper(),
            child: Container(
              height: _large
                  ? _height / 8
                  : (_medium ? _height / 7 : _height / 6.5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _large
                  ? _height / 12
                  : (_medium ? _height / 11 : _height / 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget profileImage() {
    return Stack(
      children: <Widget>[
        Container(
          height: _height / 5.5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                spreadRadius: 0.0,
                color: Colors.black26,
                offset: const Offset(1.0, 10.0),
                blurRadius: 20.0,
              ),
            ],
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: GestureDetector(
            onTap: () {
              print('Adding photo');
            },
            child: Icon(
              Icons.add_a_photo,
              size: _large ? 40 : (_medium ? 33 : 31),
              color: Colors.orange.shade200,
            ),
          ),
        ),
      ],
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
        left: _width / 12.0,
        right: _width / 12.0,
        top: _height / 20.0,
      ),
      child: Form(
        child: Column(
          children: <Widget>[
            CustomTextField(
              keyboardType: TextInputType.text,
              icon: Icons.person,
              hint: "Kullanıcı Adı",
              textEditingController: _usernameController,
            ),
            SizedBox(height: _height / 60.0),
            CustomTextField(
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
              hint: "Email",
              textEditingController: _emailController,
            ),
            SizedBox(height: _height / 60.0),
            CustomTextField(
              keyboardType: TextInputType.text,
              obscureText: true,
              icon: Icons.lock,
              hint: "Şifre",
              textEditingController: _passwordController,
            ),
          ],
        ),
      ),
    );
  }

  Widget acceptTermsTextRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Checkbox(
          activeColor: Colors.orange.shade200,
          value: checkBoxValue,
          onChanged: (bool? newValue) {
            setState(() {
              checkBoxValue = newValue ?? false;
            });
          },
        ),
        Text(
          "Tüm hüküm ve koşulları kabul ediyorum",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: _large ? 12 : (_medium ? 11 : 10),
          ),
        ),
      ],
    );
  }

  Widget button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      ),
      onPressed: () async {
        if (!checkBoxValue) {
          Get.snackbar(
            'Hata',
            'Lütfen hüküm ve koşulları kabul edin',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final username = _usernameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        try {
          final response = await AuthApi().register(username, email, password);
          Get.snackbar(
            'Durum',
            response.data['message'] ?? 'Kayıt başarılı!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } on DioError catch (e) {
          print('Dio Hata: ${e.message}');
          print(
            'Backend Hata: ${e.response?.statusCode} -> ${e.response?.data}',
          );
          Get.snackbar(
            'Hata',
            e.response?.data['detail'] ?? e.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          print('Diğer Hata: $e');
          Get.snackbar(
            'Hata',
            e.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: const Text(
        "KAYIT OL",
        style: TextStyle(color: Colors.white),
      ), // <- burada ;
    );
  }

  Widget socialIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage("assets/images/googlelogo.png"),
        ),
        const SizedBox(width: 20),
        CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage("assets/images/fblogo.jpg"),
        ),
        const SizedBox(width: 20),
        CircleAvatar(
          radius: 15,
          backgroundImage: AssetImage("assets/images/twitterlogo.jpg"),
        ),
      ],
    );
  }

  Widget backendTestButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      ),
      onPressed: () async {
        try {
          final response = await Dio().get(
            'http://10.0.2.2:8000/health',
          ); // test endpoint
          print('Başarılı: ${response.data}');
          Get.snackbar(
            'Başarılı',
            response.data.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        } on DioError catch (e) {
          print('Dio Hata: ${e.message}');
          if (e.response != null) {
            print(
              'Backend Hata: ${e.response?.statusCode} -> ${e.response?.data}',
            );
            Get.snackbar(
              'Backend Hata',
              '${e.response?.statusCode}: ${e.response?.data}',
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            Get.snackbar(
              'Network Hata',
              e.message ?? 'Bilinmeyen bir hata oluştu',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      },
      child: const Text("Backend Test", style: TextStyle(color: Colors.white)),
    );
  }
}
