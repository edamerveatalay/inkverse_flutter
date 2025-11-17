import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/app/ui/pages/drafts_edit_page.dart';
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  List<dynamic> drafts = [];
  bool isLoading = true;
  final BlogApi _blogApi = BlogApi();

  @override
  void initState() {
    super.initState();
    fetchDrafts();
  }

  Future<void> fetchDrafts() async {
    try {
      // BlogApi servisini kullan
      final response = await _blogApi.getBlogs(isPublished: false);

      setState(() {
        drafts = response;
        isLoading = false;
      });
    } catch (e) {
      print("Taslaklar alınırken hata: $e");
      setState(() => isLoading = false);
      Get.snackbar('Hata', 'Taslaklar yüklenemedi');
    }
  }

  Future<void> _publishDraft(dynamic draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // YENİ: Doğrudan Dio ile redirect ayarları
      final dio = Dio(
        BaseOptions(baseUrl: BASE_URL, followRedirects: true, maxRedirects: 5),
      );

      print("🔄 Yayınlanıyor: ${draft.id} - ${draft.title}");

      final response = await dio.put(
        '/blog/${draft.id}',
        data: {
          'title': draft.title,
          'content': draft.content,
          'is_published': true,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print("✅ Yayınlama başarılı: ${response.statusCode}");

      Get.snackbar('Başarılı', 'Blog yayınlandı!');
      await fetchDrafts(); // Listeyi güncelle
    } catch (e) {
      print("❌ Yayınlama hatası: $e");
      Get.snackbar('Hata', 'Yayınlama başarısız: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taslaklarım"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.pinkAccent],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : drafts.isEmpty
          ? const Center(
              child: Text(
                "Henüz bir taslağın yok.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchDrafts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: drafts.length,
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.pink.shade50],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            draft.title ?? 'Başlık Yok',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            draft.content ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Get.toNamed('/drafts-edit', arguments: draft);
                                },
                                child: const Text("Düzenle"),
                              ),

                              const SizedBox(width: 10),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _publishDraft(draft),
                                child: const Text("Yayınla"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
