import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as app_pages;
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:inkverse_flutter/app/models/blog.dart';

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
  final TextEditingController tagController = TextEditingController();
  List<String> tags = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.draft.title);
    contentController = TextEditingController(text: widget.draft.content);
    tags = widget.draft.tags ?? [];
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
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
        tags: tags,
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
      await _blogApi.publishBlog(
        id: widget.draft.id!,
        tags: tags, // tags listeni buradan gönderiyorsun
      );

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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Başlık TextField
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Başlık",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // İçerik TextField
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
                  const SizedBox(height: 16),

                  // Etiket ekleme TextField
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

                  // Etiketlerin gösterimi
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
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
                  ),
                  const SizedBox(height: 16),

                  // Kaydet ve Yayınla butonları
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
