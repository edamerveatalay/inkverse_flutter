// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Aşağıdaki dosyaları daha sonra oluşturacağız.
// import 'app/theme/app_theme.dart';
// import 'app/routes/app_pages.dart';

// Eğer henüz AppTheme / AppPages oluşturmadıysan geçici placeholder kullan:
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    appBarTheme: const AppBarTheme(elevation: 0),
  );
}

class AppPages {
  static const SPLASH = '/';
  static final routes = <GetPage>[];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // local storage (token vb.) için
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
