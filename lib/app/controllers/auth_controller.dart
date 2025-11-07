import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_api.dart';
import '../../services/token_storage.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var isLoading = false.obs;
  final AuthApi _authApi = AuthApi(); //sunucuya giriş isteği göndermek için
  final TokenStorage _tokenStorage =
      Get.find<TokenStorage>(); //tokenları kaydetmek silmek okumak için
  Future<void> login() async {
    isLoading.value = true; // yükleniyor göstergesi aktif

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await _authApi.login(
        email,
        password,
      ); // API'ye istek gönder

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        // tokenları güvenli şekilde kaydet
        await _tokenStorage.saveTokens(
          access: accessToken,
          refresh: refreshToken,
        );

        Get.snackbar('Başarılı', 'Giriş başarılı');
        Get.offAllNamed('/home'); // ana sayfaya yönlendir
      } else {
        Get.snackbar('Hata', 'Giriş başarısız: ${response.statusMessage}');
      }
    } catch (error) {
      Get.snackbar('Hata', 'Bir hata oluştu: $error');
    } finally {
      isLoading.value = false; // yüklenme durumu kapat
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      final hasTokens = await _tokenStorage.hasTokens();
      if (hasTokens) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (error) {
      Get.snackbar('Hata', 'Bir hata oluştu: $error');
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    Get.offAllNamed('/login'); //giriş sayfasına yönlendir
  }

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }
}
