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
  bool _showPreview = false;

  String? imageUrl;

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
      // Seçim yoksa, cursor pozisyonuna ekle
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
      // Seçim varsa, seçili metni sar
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
      // En baştaysa, "- " ekle
      contentController.text = '- ' + text;
      contentController.selection = TextSelection.collapsed(offset: 2);
      return;
    }

    // Cursor'dan önceki kısmı al
    final beforeCursor = text.substring(0, cursorPos);
    final afterCursor = text.substring(cursorPos);
    final lines = beforeCursor.split('\n');

    if (lines.isEmpty) {
      contentController.text = '- ' + text;
      contentController.selection = TextSelection.collapsed(offset: 2);
      return;
    }

    final currentLine = lines.last;

    // Otomatik liste devamı için kontrol
    if (currentLine.startsWith('- ') ||
        currentLine.startsWith('* ') ||
        currentLine.startsWith('+ ')) {
      // Zaten liste satırındaysak, yeni liste satırı ekle
      final bullet = currentLine.substring(0, 2); // "- " veya "* " veya "+ "
      contentController.text = beforeCursor + '\n' + bullet + afterCursor;
      contentController.selection = TextSelection.collapsed(
        offset: cursorPos + '\n'.length + bullet.length,
      );
    } else if (RegExp(r'^\d+\. ').hasMatch(currentLine)) {
      // Numaralı liste (1. 2. 3.)
      final match = RegExp(r'^(\d+)\. ').firstMatch(currentLine);
      if (match != null) {
        final num = int.parse(match.group(1)!);
        contentController.text = beforeCursor + '\n${num + 1}. ' + afterCursor;
        contentController.selection = TextSelection.collapsed(
          offset: cursorPos + '\n${num + 1}. '.length,
        );
      }
    } else {
      // Normal durumda "- " ekle
      contentController.text = beforeCursor + '- ' + afterCursor;
      contentController.selection = TextSelection.collapsed(
        offset: cursorPos + 2,
      );
    }
  }

  void _togglePreview() {
    setState(() {
      _showPreview = !_showPreview;
    });
  }

  void _showEmojiPicker() {
    // Basit emoji ekleme
    final emojis = ['😊', '😂', '🥰', '😎', '🤔', '🚀', '🎉', '📝', '💻', '🔗'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    child: Text(emojis[index], style: TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        imageUrl = file.path;
      });

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
      body: SafeArea(
        child: Padding(
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
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      constraints.maxHeight -
                                      50, // Toolbar için yer bırak
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

                          // SABİT TOOLBAR (AŞAĞIDA)
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
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
      ),
    );
  }
}
