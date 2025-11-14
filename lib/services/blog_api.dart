import 'package:dio/dio.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'api_client.dart';

class BlogApi {
  final ApiClient _apiClient = ApiClient();

  Future<List<Blog>> getBlogs({bool? isPublished}) async {
    try {
      final response = await _apiClient.dio.get(
        "/blog/",
        queryParameters: isPublished != null
            ? {"is_published": isPublished}
            : null,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Blog.fromJson(json)).toList();
    } catch (e) {
      print("Blog getirme hatası: $e");
      rethrow;
    }
  }

  // Blog oluşturma
  Future<Blog> createBlog({
    required String title,
    required String content,
    required bool isPublished,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        "/blog/",
        data: {'title': title, 'content': content, 'is_published': isPublished},
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Blog oluşturma hatası: $e");
      rethrow;
    }
  }

  // Blog güncelleme (yayınlama için)
  Future<Blog> updateBlog({
    required int id,
    required String title,
    required String content,
    required bool isPublished,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        "/blog/$id",
        data: {'title': title, 'content': content, 'is_published': isPublished},
      );

      return Blog.fromJson(response.data);
    } catch (e) {
      print("Blog güncelleme hatası: $e");
      rethrow;
    }
  }
}
