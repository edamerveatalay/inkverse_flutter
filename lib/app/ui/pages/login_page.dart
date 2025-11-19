import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as app_pages;
import 'package:inkverse_flutter/app/ui/widgets/custom_shape.dart';
import 'package:inkverse_flutter/app/ui/widgets/responsive_ui.dart';
import 'package:inkverse_flutter/app/ui/widgets/text_form_field.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/services/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as AppPages;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoginScreen());
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Material(
      child: Container(
        height: _height,
        width: _width,
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              clipShape(),
              welcomeTextRow(),
              signInTextRow(),
              form(),
              forgetPassTextRow(),
              SizedBox(height: _height / 12),
              button(),
              signUpTextRow(),
            ],
          ),
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
                  ? _height / 4
                  : (_medium ? _height / 3.75 : _height / 3.5),
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
                  ? _height / 4.5
                  : (_medium ? _height / 4.25 : _height / 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
          ), // Yukarı taşımak için. Yukarıyla boşlul bırakır
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30), // Köşeleri yuvarlatır
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/inkverse_logom.png',
                  height: 110, // istersen burayı büyütüp küçültebilirsin
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget welcomeTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 20, top: _height / 100),
      child: Row(
        children: <Widget>[
          Text(
            "Hoşgeldiniz",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _large ? 60 : (_medium ? 50 : 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget signInTextRow() {
    return Container(
      margin: EdgeInsets.only(left: _width / 15.0),
      child: Row(
        children: <Widget>[
          Text(
            "Hesabınıza giriş yapın",
            style: TextStyle(
              fontWeight: FontWeight.w200,
              fontSize: _large ? 20 : (_medium ? 17.5 : 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
        left: _width / 12.0,
        right: _width / 12.0,
        top: _height / 15.0,
      ),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            CustomTextField(
              keyboardType: TextInputType.emailAddress,
              textEditingController: emailController,
              icon: Icons.email,
              hint: "Email",
            ),
            SizedBox(height: _height / 40.0),
            CustomTextField(
              keyboardType: TextInputType.text,
              textEditingController: passwordController,
              icon: Icons.lock,
              obscureText: true,
              hint: "Şifre",
            ),
          ],
        ),
      ),
    );
  }

  Widget forgetPassTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Şifrenizi mi unuttunuz?",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: _large ? 14 : (_medium ? 12 : 10),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              // TODO: Şifre yenileme sayfasına yönlendirme
            },
            child: Text(
              "Şifre yenileme",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget button() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.zero,
      ),
      onPressed: () async {
        final authApi = AuthApi();

        try {
          // 1️⃣ Backend’e login isteği gönder
          final response = await authApi.login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

          if (response.statusCode == 200) {
            final data = response.data;

            final token = data['access_token'] ?? data['token'];

            if (token != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('token', token);

              print('TOKEN KAYDEDİLDİ: $token');

              Get.offAllNamed(app_pages.AppPages.HOME);
            } else {
              Get.snackbar('Hata', 'Token alınamadı');
            }
          } else {
            Get.snackbar('Hata', 'Giriş başarısız');
          }
        } catch (e) {
          print('Login Hatası: $e');
          Get.snackbar('Hata', 'Sunucuya bağlanılamadı');
        }
      },

      child: Container(
        alignment: Alignment.center,
        width: _large ? _width / 4 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [Colors.orange.shade200, Colors.pinkAccent],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'GİRİŞ YAP',
          style: TextStyle(
            fontSize: _large ? 14 : (_medium ? 15 : 10),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget signUpTextRow() {
    return Container(
      margin: EdgeInsets.only(top: _height / 120.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Hesabınız yok mu?",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: _large ? 14 : (_medium ? 12 : 10),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              Get.offAllNamed(app_pages.AppPages.SIGNUP);
            },
            child: Text(
              "Kayıt ol",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.orange.shade200,
                fontSize: _large ? 19 : (_medium ? 17 : 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
