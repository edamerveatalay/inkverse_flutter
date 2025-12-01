import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as app_pages;
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tagController = TextEditingController();
  List<String> tags = [];
  bool isLoading = false;
  final BlogApi _blogApi = BlogApi();

  String? imageUrl;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        imageUrl = file.path; // Şimdilik local path
      });

      // Burada Cloudinary upload işlemini yapabiliriz
      // imageUrl = await uploadImageToCloudinary(file)
    }
  }

  Future<void> _saveBlog(bool isPublished) async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar('Hata', 'Başlık ve içerik boş olamaz');
      return;
    }
    setState(() => isLoading = true);
    try {
      await _blogApi.createBlog(
        title: titleController.text,
        content: contentController.text,
        isPublished: isPublished,
        tags: tags,
        imageUrl: imageUrl,
      );
      Get.snackbar(
        'Başarılı',
        isPublished ? 'Blog yayınlandı!' : 'Taslak kaydedildi!',
      );
      Get.offAllNamed(app_pages.AppPages.HOME);
    } catch (e) {
      Get.snackbar('Hata', 'Blog kaydedilemedi: $e');
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
            // Başlık
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Başlık",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: imageUrl == null
                    ? const Center(
                        child: Text(
                          "Kapak görseli eklemek için dokun",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(imageUrl!), fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Markdown Editor
            Expanded(
              child: MarkdownAutoPreview(
                controller: contentController,
                enableToolBar: true,
                emojiConvert: true,
              ),
            ),

            const SizedBox(height: 20),

            // Etiketler
            TextField(
              controller: tagController,
              decoration: InputDecoration(
                labelText: "Etiket ekle (örn: flutter, dart)",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (tagController.text.trim().isNotEmpty) {
                      setState(() {
                        tags.add(tagController.text.trim());
                        tagController.clear();
                      });
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Kaydet ve Yayınla butonları
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
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Taslağı Kaydet"),
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
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Yayınla"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
