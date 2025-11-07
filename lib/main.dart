import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/ui/pages/splash_page.dart';
import 'app/ui/pages/login_page.dart';
import 'app/ui/pages/signup_page.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    appBarTheme: const AppBarTheme(elevation: 0),
  );
}

class AppPages {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';

  static final routes = <GetPage>[
    GetPage(name: SPLASH, page: () => const SplashPage()),
    GetPage(name: LOGIN, page: () => const LoginPage()),
    GetPage(name: SIGNUP, page: () => const SignUpPage()),
  ];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const InkverseApp());
}

class InkverseApp extends StatelessWidget {
  const InkverseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inkverse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
