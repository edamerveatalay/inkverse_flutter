import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';
import 'package:inkverse_flutter/app/ui/pages/add_blog_page.dart';
import 'package:inkverse_flutter/app/ui/pages/drafts_page.dart';
import 'package:inkverse_flutter/main.dart';
import 'package:inkverse_flutter/services/blog_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/routers/app_pages.dart';

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
                                    Text(
                                      blog.content ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                    ),
                                    Text(
                                      blog.title ?? 'Başlık Yok',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      blog.content != null
                                          ? blog.content.length > 100
                                                ? blog.content.substring(
                                                        0,
                                                        100,
                                                      ) +
                                                      "..."
                                                : blog.content
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "- Anonim", // sabit metin veya user_id gösterebilirsin

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

class BlogDetailPage extends StatelessWidget {
  final dynamic blog;
  const BlogDetailPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiketler
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

              // Başlık
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
            ],
          ),
        ),
      ),
    );
  }
}
