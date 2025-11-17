import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as app_pages;
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'package:inkverse_flutter/app/ui/pages/drafts_page.dart';

class DraftsEditPage extends StatefulWidget {
  final Blog draft;
  const DraftsEditPage({super.key, required this.draft});

  @override
  State<DraftsEditPage> createState() => _DraftsEditPageState();
}

class _DraftsEditPageState extends State<DraftsEditPage> {
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

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar('Hata', 'Başlık ve içerik boş olamaz');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _blogApi.updateDraftBlog(
        id: widget.draft.id!,
        title: titleController.text,
        content: contentController.text,
      );

      Get.snackbar("Başarılı", "Taslak güncellendi");

      Get.offAllNamed(app_pages.AppPages.DRAFTS);
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

      Get.offAllNamed(app_pages.AppPages.DRAFTS);
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
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Başlık",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: "İçerik",
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : _saveDraft,
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Kaydet"),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : _publishDraft,
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
