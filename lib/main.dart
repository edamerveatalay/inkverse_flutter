import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    appBarTheme: const AppBarTheme(elevation: 0),
  );
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
