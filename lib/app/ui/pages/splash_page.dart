import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:inkverse_flutter/main.dart'; // AppPages.LOGIN burada tanımlı olmalı

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    // Animasyon ayarları
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    animation.addListener(() {
      setState(() {}); // animasyonu tetiklemek için
    });

    animationController.forward();

    // Splash süresi
    Timer(const Duration(seconds: 3), navigationPage);
  }

  void navigationPage() {
    Get.offNamed(AppPages.LOGIN); // login sayfasına geç
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Arka plan rengi
          Container(color: Colors.white),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: animation.value * 200, // animasyonlu boyut
                height: animation.value * 200,
                child: Image.asset(
                  'assets/images/inkverse_logo_2.png', // burası logon
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
