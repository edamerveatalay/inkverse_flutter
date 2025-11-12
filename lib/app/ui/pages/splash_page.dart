import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    // Splash bitince login durumunu kontrol et
    Timer(const Duration(seconds: 3), _checkLoginStatus);
  }

  /// Kullanıcının giriş yapıp yapmadığını kontrol eder
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Token varsa home’a, yoksa login’e yönlendir
    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(HOME_PAGE);
    } else {
      Get.offAllNamed(AppPages.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: Colors.white),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: _animation.value * 200,
                height: _animation.value * 200,
                child: Image.asset(
                  'assets/images/inkverse_logo_2.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
