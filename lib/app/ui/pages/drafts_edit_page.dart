import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:inkverse_flutter/app/models/blog.dart';

class DraftEditPage extends StatefulWidget {
  final Blog draft;

  const DraftEditPage({super.key, required this.draft});

  @override
  State<DraftEditPage> createState() => _DraftEditPageState();
}

class _DraftEditPageState extends State<DraftEditPage> {
  final BlogApi _blogApi = BlogApi();

  late TextEditingController titleController;
  late TextEditingController contentController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.draft.title);
    contentController = TextEditingController(text: widget.draft.content);
  }

  Future<void> _saveDraft() async {
    setState(() => isLoading = true);

    try {
      await _blogApi.updateDraftBlog(
        id: widget.draft.id!,
        title: titleController.text,
        content: contentController.text,
      );

      Get.snackbar("Başarılı", "Taslak güncellendi");
      Get.back(); // sayfayı kapat
    } catch (e) {
      Get.snackbar("Hata", "Taslak güncellenemedi: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _publishDraft() async {
    setState(() => isLoading = true);

    try {
      await _blogApi.publishBlog(widget.draft.id!);

      Get.snackbar("Başarılı", "Taslak yayınlandı!");
      Get.back(); // sayfayı kapat
    } catch (e) {
      Get.snackbar("Hata", "Yayınlama başarısız: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taslağı Düzenle"),
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Başlık",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Başlığı gir...",
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    "İçerik",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "İçeriği yaz...",
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _saveDraft,
                          child: const Text("Kaydet"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _publishDraft,
                          child: const Text("Yayınla"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
