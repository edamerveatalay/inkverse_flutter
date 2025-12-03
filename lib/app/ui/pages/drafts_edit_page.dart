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

  // MARKDOWN TOOLBAR FONKSİYONLARI
  Widget _buildToolbarButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.pinkAccent),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _insertText(String prefix, String suffix) {
    final text = contentController.text;
    final selection = contentController.selection;

    if (selection.start == -1) {
      final cursorPos = selection.baseOffset;
      final newText =
          text.substring(0, cursorPos) +
          prefix +
          suffix +
          text.substring(cursorPos);
      contentController.text = newText;
      contentController.selection = TextSelection.collapsed(
        offset: cursorPos + prefix.length,
      );
    } else {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix${selection.textInside(text)}$suffix',
      );
      contentController.text = newText;
      contentController.selection = TextSelection.collapsed(
        offset:
            selection.start +
            prefix.length +
            selection.textInside(text).length +
            suffix.length,
      );
    }
  }

  void _insertListItem() {
    final text = contentController.text;
    final selection = contentController.selection;
    final cursorPos = selection.baseOffset;

    if (cursorPos == 0) {
      contentController.text = '- ' + text;
      contentController.selection = TextSelection.collapsed(offset: 2);
      return;
    }

    final beforeCursor = text.substring(0, cursorPos);
    final afterCursor = text.substring(cursorPos);
    final lines = beforeCursor.split('\n');

    if (lines.isEmpty) {
      contentController.text = '- ' + text;
      contentController.selection = TextSelection.collapsed(offset: 2);
      return;
    }

    final currentLine = lines.last;

    if (currentLine.startsWith('- ') ||
        currentLine.startsWith('* ') ||
        currentLine.startsWith('+ ')) {
      final bullet = currentLine.substring(0, 2);
      contentController.text = beforeCursor + '\n' + bullet + afterCursor;
      contentController.selection = TextSelection.collapsed(
        offset: cursorPos + '\n'.length + bullet.length,
      );
    } else if (RegExp(r'^\d+\. ').hasMatch(currentLine)) {
      final match = RegExp(r'^(\d+)\. ').firstMatch(currentLine);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        contentController.text = beforeCursor + '\n${num + 1}. ' + afterCursor;
        contentController.selection = TextSelection.collapsed(
          offset: cursorPos + '\n${num + 1}. '.length,
        );
      }
    } else {
      contentController.text = beforeCursor + '- ' + afterCursor;
      contentController.selection = TextSelection.collapsed(
        offset: cursorPos + 2,
      );
    }
  }

  void _showEmojiPicker() {
    final emojis = ['😊', '😂', '🥰', '😎', '🤔', '🚀', '🎉', '📝', '💻', '🔗'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _insertText(emojis[index], '');
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      emojis[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              // EDITOR ALANI (Scrollable)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Editor'e tıklandığında klavyeyi aç
                                    print("Editor'e tıklandı!");
                                    // Önce mevcut odağı kapat
                                    FocusScope.of(context).unfocus();
                                    // Sonra editor'e odaklan
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        final focusNode = FocusNode();
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(focusNode);
                                        Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                            focusNode.dispose();
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight - 50,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: MarkdownAutoPreview(
                                          controller: contentController,
                                          emojiConvert: true,
                                          enableToolBar: true,
                                          decoration: const InputDecoration(
                                            hintText: '''İçeriğini yaz...

# Başlık için
## Alt başlık için
**kalın** için
*italik* için
- liste için (• butonuna tıkla)
> alıntı için  
\`\`\`kod bloğu için\`\`\`
[bağlantı](url) için

''',
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // SABİT TOOLBAR (AŞAĞIDA)
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      _buildToolbarButton(
                                        'B',
                                        Icons.format_bold,
                                        () => _insertText('**', '**'),
                                      ),
                                      _buildToolbarButton(
                                        'I',
                                        Icons.format_italic,
                                        () => _insertText('*', '*'),
                                      ),
                                      _buildToolbarButton(
                                        'H1',
                                        Icons.title,
                                        () => _insertText('# ', ''),
                                      ),
                                      _buildToolbarButton(
                                        'H2',
                                        Icons.title,
                                        () => _insertText('## ', ''),
                                      ),
                                      _buildToolbarButton(
                                        '•',
                                        Icons.format_list_bulleted,
                                        _insertListItem,
                                      ),
                                      _buildToolbarButton(
                                        '😊',
                                        Icons.emoji_emotions,
                                        _showEmojiPicker,
                                      ),
                                      _buildToolbarButton(
                                        '>',
                                        Icons.format_quote,
                                        () => _insertText('> ', ''),
                                      ),
                                      _buildToolbarButton(
                                        '```',
                                        Icons.code,
                                        () => _insertText('```\n', '\n```'),
                                      ),
                                      _buildToolbarButton(
                                        'Link',
                                        Icons.link,
                                        () => _insertText('[', '](url)'),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
