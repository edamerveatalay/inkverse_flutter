import 'package:get/get.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'package:inkverse_flutter/services/blog_api.dart';

class BlogController extends GetxController {
  // Taslak blogları tutacak liste
  var draftBlogs = <Blog>[].obs;

  // Yükleniyor mu durumu
  var isLoading = false.obs;

  // Blog API servisi
  final BlogApi _blogApi = BlogApi();

  // Taslakları çekme fonksiyonu
  Future<void> fetchDraftBlogs() async {
    try {
      isLoading.value = true;

      // Backend'den taslakları çek
      final blogs = await _blogApi.getBlogs(isPublished: false);

      // Listeyi güncelle
      draftBlogs.value = blogs;
    } catch (e) {
      print("Taslak blogları çekme hatası: $e");
      // Hata durumunu UI'da göstermek için snack veya başka mekanizma eklenebilir
    } finally {
      isLoading.value = false;
    }
  }
}
