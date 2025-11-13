import 'package:dio/dio.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'api_client.dart';

class BlogApi {
  final ApiClient _apiClient = ApiClient();

  Future<List<Blog>> getBlogs({bool? isPublished}) async {
    try {
      final response = await _apiClient.dio.get(
        "/blog/",
        queryParameters: {"is_published": isPublished},
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Blog.fromJson(json)).toList();
    } catch (e) {
      print("Blog API hatası: $e");
      return [];
    }
  }
}
