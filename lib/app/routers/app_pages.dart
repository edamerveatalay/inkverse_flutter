import 'package:get/get.dart';
import 'package:inkverse_flutter/app/ui/pages/home_page.dart';
import 'package:inkverse_flutter/app/ui/pages/login_page.dart';
import 'package:inkverse_flutter/app/ui/pages/signup_page.dart';
import 'package:inkverse_flutter/app/ui/pages/splash_page.dart';

class AppPages {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const HOME = '/home';

  static final routes = <GetPage>[
    GetPage(name: SPLASH, page: () => const SplashPage()),
    GetPage(name: LOGIN, page: () => const LoginPage()),
    GetPage(name: SIGNUP, page: () => const SignUpPage()),
    GetPage(name: HOME, page: () => const HomePage()),
  ];
}
