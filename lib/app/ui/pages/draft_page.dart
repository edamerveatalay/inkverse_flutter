import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:inkverse_flutter/app/constants/constants.dart';

class DraftsPage extends StatefulWidget {
  const DraftsPage({super.key});

  @override
  State<DraftsPage> createState() => _DraftsPageState();
}

class _DraftsPageState extends State<DraftsPage> {
  List<dynamic> drafts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrafts();
  }

  Future<void> fetchDrafts() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: BASE_URL));
      final response = await dio.get('/blogs/?is_published=false');
      if (response.statusCode == 200) {
        setState(() {
          drafts = response.data;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Taslaklar alınırken hata: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taslaklarım"),
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
          : drafts.isEmpty
          ? const Center(
              child: Text(
                "Henüz bir taslağın yok.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: fetchDrafts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: drafts.length,
                itemBuilder: (context, index) {
                  final draft = drafts[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.pink.shade50],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            draft['title'] ?? 'Başlık Yok',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            draft['content'] ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  final dio = Dio(
                                    BaseOptions(baseUrl: BASE_URL),
                                  );
                                  await dio.patch(
                                    '/blog/${draft['id']}',
                                    data: {'is_published': true},
                                  );
                                  fetchDrafts();
                                } catch (e) {
                                  print("Yayınlama hatası: $e");
                                }
                              },
                              child: const Text("Yayınla"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
