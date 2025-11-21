import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/app/ui/pages/add_blog_page.dart';
import 'package:inkverse_flutter/app/ui/pages/drafts_page.dart';
import 'package:inkverse_flutter/main.dart';
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/models/comment.dart';
import 'package:inkverse_flutter/services/comment_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> blogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    try {
      final BlogApi blogApi = BlogApi();
      final publishedBlogs = await blogApi.getBlogs(isPublished: true);

      setState(() {
        blogs = publishedBlogs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Blogları çekerken hata: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Get.offAllNamed(AppPages.LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inkverse"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade200, Colors.pinkAccent],
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchBlogs,
              child: blogs.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz yayınlanmış blog bulunmuyor.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: blogs.length,
                      itemBuilder: (context, index) {
                        final blog = blogs[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => BlogDetailPage(blog: blog));
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.shade50,
                                    Colors.pink.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (blog.tags != null &&
                                        (blog.tags as List).isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: (blog.tags as List<String>)
                                            .map((tag) {
                                              return Chip(
                                                label: Text(tag),
                                                backgroundColor:
                                                    Colors.orange.shade100,
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              );
                                            })
                                            .toList(),
                                      ),
                                    const SizedBox(height: 16),
                                    // Blog içeriği
                                    // Başlık
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            blog.title ?? 'Başlık Yok',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  "Emin misiniz?",
                                                ),
                                                content: const Text(
                                                  "Bu blogu silmek istediğinize emin misiniz?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text("İptal"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    child: const Text("Sil"),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              try {
                                                await BlogApi().deleteBlog(
                                                  blog.id,
                                                );
                                                setState(() {
                                                  blogs.remove(blog);
                                                });
                                                Get.snackbar(
                                                  'Başarılı',
                                                  'Blog silindi',
                                                );
                                              } catch (e) {
                                                Get.snackbar(
                                                  'Hata',
                                                  'Blog silinirken bir hata oluştu',
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                    // Özet
                                    Text(
                                      blog.content != null
                                          ? (blog.content!.length > 100
                                                ? blog.content!.substring(
                                                        0,
                                                        100,
                                                      ) +
                                                      "..."
                                                : blog.content!)
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),

                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Yazar: ${blog.user?.username ?? 'Bilinmiyor'}",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade200,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Get.to(() => const AddBlogPage());
          if (result == true) {
            await fetchBlogs(); // yeni blog eklendiğinde listeyi yenile
          }
        },
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.pinkAccent),
                onPressed: () {}, // zaten buradayız
              ),
              IconButton(
                icon: const Icon(Icons.drafts_outlined, color: Colors.grey),
                onPressed: () {
                  Get.toNamed(AppPages.DRAFTS);
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.grey),
                onPressed: () {
                  Get.toNamed(PROFILE);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogDetailPage extends StatefulWidget {
  final dynamic blog;
  const BlogDetailPage({super.key, required this.blog});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final CommentApi _commentApi = CommentApi();
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Not: login sırasında user_id kaydetmiş olman lazım: prefs.setInt('user_id', user.id)
    setState(() {
      _currentUserId = prefs.getInt('user_id');
    });
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _commentApi.getComments(widget.blog.id);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
      debugPrint("Yorumları çekerken hata: $e");
      Get.snackbar('Hata', 'Yorumlar yüklenemedi');
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final newComment = await _commentApi.addComment(
        blogId: widget.blog.id,
        content: text,
      );
      _commentController.clear();
      setState(() {
        _comments.insert(0, newComment);
      });
      Get.snackbar('Başarılı', 'Yorum eklendi');
    } catch (e) {
      debugPrint("Yorum ekleme hatası: $e");
      Get.snackbar('Hata', 'Yorum eklenirken hata oluştu');
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yorumu sil"),
        content: const Text("Bu yorumu silmek istediğinizden emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sil"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _commentApi.deleteComment(commentId: commentId);
      setState(() {
        _comments.removeWhere((c) => c.id == commentId);
      });
      Get.snackbar('Başarılı', 'Yorum silindi');
    } catch (e) {
      debugPrint("Yorum silme hatası: $e");
      Get.snackbar('Hata', 'Yorum silinirken hata oluştu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;

    return Scaffold(
      appBar: AppBar(
        title: Text(blog.title ?? "Detay"),
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
            // Blog içeriği
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (blog.tags != null && (blog.tags as List).isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (blog.tags as List<String>).map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.orange.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),

                    Text(
                      blog.title ?? 'Başlık Yok',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      blog.content ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),

                    const SizedBox(height: 24),

                    // Yorum başlığı + yenile
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Yorumlar",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _fetchComments,
                          tooltip: "Yorumları yenile",
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Yorum listesi
                    if (_isLoadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      const Text("Henüz yorum yok. İlk yorumu siz yazın!")
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final c = _comments[index];
                          return ListTile(
                            title: Text(c.content),
                            subtitle: Text(
                              c.author != null
                                  ? "${c.author} • ${c.createdAt.toLocal()}"
                                  : "Kullanıcı ${c.userId} • ${c.createdAt.toLocal()}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing:
                                (_currentUserId != null &&
                                    c.userId == _currentUserId)
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteComment(c.id),
                                  )
                                : null,
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: _comments.length,
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Yorum gönderme alanı
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Yorum yaz...",
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _postComment,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
