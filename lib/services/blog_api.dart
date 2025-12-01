import 'package:dio/dio.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'api_client.dart';

class BlogApi {
  final ApiClient _apiClient = ApiClient();

  /// Yayınlanmış / taslak blogları getir
  Future<List<Blog>> getBlogs({bool? isPublished}) async {
    try {
      final response = await _apiClient.dio.get(
        "/blog/",
        queryParameters: isPublished != null
            ? {"is_published": isPublished}
            : null,
      );

      final data = response.data as List;
      return data.map((json) => Blog.fromJson(json)).toList();
    } catch (e) {
      print("Blog getirme hatası: $e");
      rethrow;
    }
  }

  Future<List<Blog>> getMyDrafts() async {
    try {
      final response = await _apiClient.dio.get("/blog/drafts");

      final data = response.data as List;
      return data.map((json) => Blog.fromJson(json)).toList();
    } catch (e) {
      print("Kullanıcı taslaklarını getirme hatası: $e");
      rethrow;
    }
  }

  /// Yeni blog oluşturma
  Future<Blog> createBlog({
    required String title,
    required String content,
    required bool isPublished,
    required List<String> tags,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        "/blog/",
        data: {
          'title': title,
          'content': content,
          'is_published': isPublished,
          'tags': tags,
          'image_url': imageUrl,
        },
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Blog oluşturma hatası: $e");
      rethrow;
    }
  }

  /// Taslak güncelleme
  Future<Blog> updateDraftBlog({
    required int id,
    required String title,
    required String content,
    List<String>? tags,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        "/blog/$id",
        data: {
          'title': title,
          'content': content,
          'is_published': false,
          'tags': tags ?? [],
        },
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Taslak güncelleme hatası: $e");
      rethrow;
    }
  }

  /// Taslak yayınlama
  Future<Blog> publishBlog({required int id, List<String>? tags}) async {
    try {
      final response = await _apiClient.dio.put(
        "/blog/$id",
        data: {'is_published': true, 'tags': tags ?? []},
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Yayınlama hatası: $e");
      rethrow;
    }
  }

  /// Yayınlanmış blog güncelleme
  Future<Blog> updatePublishedBlog({
    required int id,
    required String title,
    required String content,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        "/blog/$id",
        data: {'title': title, 'content': content, 'is_published': true},
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Yayınlanmış blog güncelleme hatası: $e");
      rethrow;
    }
  }

  Future<void> deleteBlog(int blogId) async {
    try {
      final response = await _apiClient.dio.delete('/blog/$blogId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Blog silinemedi');
      }
    } catch (e) {
      print("Blog silme hatası: $e");
      rethrow;
    }
  }

  /// Blog beğenme
  Future<bool> likeBlog(int blogId) async {
    try {
      final response = await _apiClient.dio.post(
        "/likes/",
        data: {"blog_id": blogId},
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Beğenme hatası: $e");
      return false;
    }
  }

  ///  Blog beğenisini kaldırma
  Future<bool> unlikeBlog(int blogId) async {
    try {
      final response = await _apiClient.dio.delete(
        "/likes/",
        queryParameters: {"blog_id": blogId},
      );
      return response.statusCode == 204;
    } catch (e) {
      print("Beğeni kaldırma hatası: $e");
      return false;
    }
  }

  ///  Kullanıcı bu blogu beğenmiş mi?
  Future<bool> checkLikeStatus(int blogId) async {
    try {
      final response = await _apiClient.dio.get(
        "/likes/",
        queryParameters: {"blog_id": blogId},
      );

      // Eğer backend beğeni varsa LikeRead döndürüyor, yoksa null
      return response.data != null;
    } catch (e) {
      return false; // beğeni yoksa
    }
  }
}
