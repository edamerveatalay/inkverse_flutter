import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'package:inkverse_flutter/app/models/comment.dart';
import 'package:inkverse_flutter/app/ui/pages/add_blog_page.dart';
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:inkverse_flutter/services/comment_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String getFullImageUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (url.startsWith("http://") || url.startsWith("https://")) {
      return url; // zaten tam URL
    }
    return "$BASE_URL/$url";
  }

  List<Blog> blogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> fetchBlogs() async {
    setState(() => isLoading = true);
    try {
      final BlogApi blogApi = BlogApi();
      final publishedBlogs = await blogApi.getBlogs(isPublished: true);
      setState(() {
        blogs = publishedBlogs;
        // En yeni blog en üstte olacak şekilde sırala
        blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
                      padding: const EdgeInsets.all(16),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (blog.imageUrl != null &&
                                      blog.imageUrl!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          blog.imageUrl != null &&
                                              blog.imageUrl!.startsWith(
                                                "/data/",
                                              )
                                          ? Image.file(
                                              File(blog.imageUrl!),
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              getFullImageUrl(blog.imageUrl),
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),

                                  const SizedBox(height: 12),

                                  if (blog.tags.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: blog.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag),
                                          backgroundColor:
                                              Colors.orange.shade100,
                                          labelStyle: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  const SizedBox(height: 12),
                                  Text(
                                    blog.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    blog.content.length > 100
                                        ? "${blog.content.substring(0, 100)}..."
                                        : blog.content,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          blog.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: blog.isLiked
                                              ? Colors.pinkAccent
                                              : Colors.grey[600],
                                        ),
                                        onPressed: () async {
                                          print(
                                            '🎯 Like butonuna basıldı: Blog ${blog.id}',
                                          );

                                          // Optimistik güncelleme
                                          final oldLiked = blog.isLiked;
                                          final oldLikesCount = blog.likesCount;

                                          setState(() {
                                            if (blog.isLiked) {
                                              // Unlike
                                              blog.isLiked = false;
                                              blog.likesCount = max(
                                                0,
                                                blog.likesCount - 1,
                                              );
                                            } else {
                                              // Like
                                              blog.isLiked = true;
                                              blog.likesCount =
                                                  blog.likesCount + 1;
                                            }
                                          });

                                          try {
                                            final api = BlogApi();
                                            bool success;

                                            if (oldLiked) {
                                              success = await api.unlikeBlog(
                                                blog.id,
                                              );
                                            } else {
                                              success = await api.likeBlog(
                                                blog.id,
                                              );
                                            }

                                            if (!success) {
                                              // İşlem başarısız olursa geri al
                                              setState(() {
                                                blog.isLiked = oldLiked;
                                                blog.likesCount = oldLikesCount;
                                              });

                                              Get.snackbar(
                                                'Hata',
                                                'Beğeni işlemi başarısız',
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            } else {
                                              Get.snackbar(
                                                'Başarılı',
                                                blog.isLiked
                                                    ? 'Beğenildi!'
                                                    : 'Beğeni kaldırıldı',
                                                backgroundColor: Colors.green,
                                                colorText: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            // Hata durumunda geri al
                                            setState(() {
                                              blog.isLiked = oldLiked;
                                              blog.likesCount = oldLikesCount;
                                            });

                                            Get.snackbar(
                                              'Hata',
                                              'Beğeni işlemi sırasında hata: $e',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${blog.likesCount ?? 0} Beğeni",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text("Blogu sil"),
                                              content: const Text(
                                                "Bu blogu silmek istediğinizden emin misiniz?",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: const Text("İptal"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  child: const Text("Sil"),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm != true) return;

                                          try {
                                            await BlogApi().deleteBlog(blog.id);
                                            setState(() {
                                              blogs.removeAt(index);
                                            });
                                            Get.snackbar(
                                              'Başarılı',
                                              'Blog silindi',
                                            );
                                          } catch (e) {
                                            debugPrint('Blog silme hatası: $e');
                                            Get.snackbar(
                                              'Hata',
                                              'Blog silinemedi',
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
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
            await fetchBlogs();
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
                onPressed: () {},
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
                  Get.toNamed(AppPages.PROFILE);
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
  final Blog blog;
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
        title: Text(blog.title),
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (blog.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: blog.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.orange.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      blog.content,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            blog.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: blog.isLiked
                                ? Colors.pinkAccent
                                : Colors.grey[600],
                            size: 30,
                          ),
                          onPressed: () async {
                            print('🎯 Blog detay: Like butonuna basıldı');

                            // Optimistik güncelleme
                            final oldLiked = blog.isLiked;
                            final oldLikesCount = blog.likesCount;

                            setState(() {
                              blog.isLiked = !blog.isLiked;
                              blog.likesCount = blog.isLiked
                                  ? blog.likesCount + 1
                                  : max(0, blog.likesCount - 1);
                            });

                            try {
                              final api = BlogApi();
                              bool success;

                              if (oldLiked) {
                                success = await api.unlikeBlog(blog.id);
                              } else {
                                success = await api.likeBlog(blog.id);
                              }

                              if (!success) {
                                // İşlem başarısız olursa geri al
                                setState(() {
                                  blog.isLiked = oldLiked;
                                  blog.likesCount = oldLikesCount;
                                });

                                Get.snackbar(
                                  'Hata',
                                  'Beğeni işlemi başarısız',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                // Başarılı - güncel blog detayını getir
                                try {
                                  final updatedBlog = await api.getBlogDetail(
                                    blog.id,
                                  );
                                  setState(() {
                                    blog.isLiked = updatedBlog.isLiked;
                                    blog.likesCount = updatedBlog.likesCount;
                                  });
                                } catch (e) {
                                  print('Blog detay yenileme hatası: $e');
                                }

                                Get.snackbar(
                                  'Başarılı',
                                  blog.isLiked
                                      ? 'Beğenildi!'
                                      : 'Beğeni kaldırıldı',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                  duration: Duration(seconds: 2),
                                );
                              }
                            } catch (e) {
                              // Hata durumunda geri al
                              setState(() {
                                blog.isLiked = oldLiked;
                                blog.likesCount = oldLikesCount;
                              });

                              Get.snackbar(
                                'Hata',
                                'Beğeni işlemi sırasında hata: $e',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    if (_isLoadingComments)
                      const Center(child: CircularProgressIndicator())
                    else if (_comments.isEmpty)
                      const Text("Henüz yorum yok. İlk yorumu siz yazın!")
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const Divider(),
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
                      ),
                  ],
                ),
              ),
            ),
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
