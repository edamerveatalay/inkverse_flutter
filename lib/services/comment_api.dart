// lib/services/comment_api.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inkverse_flutter/app/models/comment.dart';
import 'package:inkverse_flutter/services/api_client.dart';

class CommentApi {
  final ApiClient _apiClient = ApiClient();

  /// Blog'a ait yorumları getir
  Future<List<Comment>> getComments(int blogId) async {
    try {
      final response = await _apiClient.dio.get(
        "/",
        queryParameters: {"blog_id": blogId},
      );

      final data = response.data as List;
      return data.map((e) => Comment.fromJson(e)).toList();
    } catch (e) {
      print("Yorumları çekerken hata: $e");
      rethrow;
    }
  }

  /// Yorum ekle
  Future<Comment> addComment({
    required int blogId,
    required String content,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _apiClient.dio.post(
        "/",
        queryParameters: {"blog_id": blogId},
        data: {"content": content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      print("Yorum ekleme hatası: $e");
      rethrow;
    }
  }

  /// Yorum güncelle
  Future<Comment> updateComment({
    required int commentId,
    required String content,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _apiClient.dio.put(
        "/",
        queryParameters: {"comment_id": commentId},
        data: {"content": content},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      print("Yorum güncelleme hatası: $e");
      rethrow;
    }
  }

  /// Yorum sil
  Future<Comment> deleteComment({required int commentId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _apiClient.dio.delete(
        "/",
        queryParameters: {"comment_id": commentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Comment.fromJson(response.data);
    } catch (e) {
      print("Yorum silme hatası: $e");
      rethrow;
    }
  }
}
