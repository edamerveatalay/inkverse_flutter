import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart' as app_pages;
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

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
  File? selectedImage;
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
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
        imageUrl: selectedImage?.path ?? widget.draft.imageUrl,
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
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar('Hata', 'Başlık ve içerik boş olamaz');
      return;
    }

    setState(() => isLoading = true);
    try {
      await _blogApi.publishDraftBlog(
        id: widget.draft.id!,
        title: titleController.text,
        content: contentController.text,
        tags: tags,
        imageUrl: selectedImage?.path ?? widget.draft.imageUrl,
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
                  /// BAŞLIK
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Başlık",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// FOTOĞRAF SEÇME / GÖSTERME
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.draft.imageUrl != null &&
                                widget.draft.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.draft.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// İÇERİK
                  Expanded(
                    child: MarkdownAutoPreview(
                      controller: contentController,
                      enableToolBar: true,
                      emojiConvert: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// ETİKET EKLEME
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

                  /// ETİKETLERİN GÖSTERİLMESİ
                  Wrap(
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
                  const SizedBox(height: 16),

                  /// BUTONLAR: Kaydet + Yayınla
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isLoading ? null : _saveDraft,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Kaydet"),
                      ),
                      ElevatedButton(
                        onPressed: isLoading ? null : _publishDraft,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
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
