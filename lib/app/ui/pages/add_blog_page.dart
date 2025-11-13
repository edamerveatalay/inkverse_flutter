import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isLoading = false;

  Future<void> _saveBlog(bool isPublished) async {
    setState(() => isLoading = true);
    try {
      final dio = Dio(BaseOptions(baseUrl: BASE_URL));
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await dio.post(
        '/blog/',
        data: {
          'title': titleController.text,
          'content': contentController.text,
          'is_published': isPublished,
        },
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      print(
        "Taslak kaydetme response: ${response.statusCode} - ${response.data}",
      );

      Get.back(result: true);
    } catch (e) {
      print("Hata: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Blog Yaz"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.pinkAccent],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Başlık"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "İçerik"),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : () => _saveBlog(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Taslağı Kaydet"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _saveBlog(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Yayınla"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
