import 'dart:io';
import 'dart:convert'; // JSON decode için

import 'package:dio/dio.dart';
import 'package:inkverse_flutter/app/models/blog.dart';
import 'api_client.dart';

class BlogApi {
  final ApiClient _apiClient = ApiClient();

  /// Yayınlanmış / taslak blogları getir
  Future<List<Blog>> getBlogs({bool? isPublished}) async {
    try {
      print('🔄 BlogApi: Blog listesi isteniyor...');

      final response = await _apiClient.dio.get(
        "/blog/",
        queryParameters: isPublished != null
            ? {"is_published": isPublished}
            : null,
      );

      print('📊 Status Code: ${response.statusCode}');

      final data = response.data as List;

      // DEBUG: İlk blog'un verilerini göster
      if (data.isNotEmpty) {
        final firstBlog = data[0];
        print('📝 İlk Blog Debug:');
        print('   - ID: ${firstBlog['id']}');
        print('   - Title: ${firstBlog['title']}');
        print('   - Likes Count: ${firstBlog['likes_count']}');
        print('   - Is Liked: ${firstBlog['is_liked']}');
        print('   - User: ${firstBlog['user']?['username']}');

        // Tüm anahtarları göster
        print('   - Tüm anahtarlar: ${firstBlog.keys.toList()}');
      }

      return data.map((json) {
        print('📦 Blog.fromJson için JSON: $json');
        return Blog.fromJson(json);
      }).toList();
    } catch (e) {
      print("🔴 Blog getirme hatası: $e");
      rethrow;
    }
  }

  /// YENİ: Blog detayını getir
  Future<Blog> getBlogDetail(int blogId) async {
    try {
      print('🔄 Blog detayı isteniyor: $blogId');

      final response = await _apiClient.dio.get("/blog/$blogId");

      print('📊 Blog detail Status: ${response.statusCode}');
      print('📊 Blog detail Data: ${response.data}');

      return Blog.fromJson(response.data);
    } catch (e) {
      print("🔴 Blog detay hatası: $e");
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
    String? imageUrl,
  }) async {
    final response = await _apiClient.dio.put(
      "/blog/$id",
      data: {
        'title': title,
        'content': content,
        'is_published': false,
        'tags': tags,
        'image_url': imageUrl,
      },
    );
    return Blog.fromJson(response.data);
  }

  /// Taslak yayınlama
  Future<Blog> publishDraftBlog({
    required int id,
    required String title,
    required String content,
    List<String>? tags,
    String? imageUrl,
  }) async {
    final response = await _apiClient.dio.post(
      "/blog/$id/publish",
      data: {
        'title': title,
        'content': content,
        'tags': tags,
        'image_url': imageUrl,
      },
    );
    return Blog.fromJson(response.data);
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

  /// Blog beğenme - GÜNCELLENDİ
  Future<bool> likeBlog(int blogId) async {
    try {
      print('🔄 Like isteği gönderiliyor: Blog $blogId');

      final response = await _apiClient.dio.post(
        "/likes/",
        data: {"blog_id": blogId},
      );

      print('✅ Like response: ${response.statusCode}');
      print('✅ Like response data: ${response.data}');

      if (response.statusCode == 201) {
        return true;
      } else {
        print('🔴 Like failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("🔴 Beğenme hatası: $e");

      // DioError tipinde mi kontrol et
      if (e is DioException) {
        print('🔴 DioError Details:');
        print('   - Type: ${e.type}');
        print('   - Message: ${e.message}');
        print('   - Response: ${e.response?.data}');
        print('   - Status: ${e.response?.statusCode}');
      }

      return false;
    }
  }

  /// Blog beğenisini kaldırma - GÜNCELLENDİ
  Future<bool> unlikeBlog(int blogId) async {
    try {
      print('🔄 Unlike isteği gönderiliyor: Blog $blogId');

      final response = await _apiClient.dio.delete(
        "/likes/",
        queryParameters: {"blog_id": blogId},
      );

      print('✅ Unlike response: ${response.statusCode}');
      print('✅ Unlike response data: ${response.data}');

      // Backend'de 200 veya 204 olabilir
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('🔴 Unlike failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print("🔴 Beğeni kaldırma hatası: $e");

      // DioError tipinde mi kontrol et
      if (e is DioException) {
        print('🔴 DioError Details:');
        print('   - Type: ${e.type}');
        print('   - Message: ${e.message}');
        print('   - Response: ${e.response?.data}');
        print('   - Status: ${e.response?.statusCode}');
      }

      return false;
    }
  }

  /// Kullanıcı bu blogu beğenmiş mi? - GÜNCELLENDİ
  Future<bool> checkLikeStatus(int blogId) async {
    try {
      print('🔄 Like durumu kontrol ediliyor: Blog $blogId');

      final response = await _apiClient.dio.get(
        "/likes/check",
        queryParameters: {"blog_id": blogId},
      );

      print('✅ Like check response: ${response.statusCode}');
      print('✅ Like check data: ${response.data}');

      // Backend: { "is_liked": true/false }
      if (response.data != null && response.data is Map) {
        return response.data["is_liked"] ?? false;
      }

      return false;
    } catch (e) {
      print("🔴 Like check hatası: $e");

      // 404 → beğeni yok
      if (e is DioException && e.response?.statusCode == 404) {
        return false;
      }

      return false;
    }
  }

  /// YENİ: Like toggle (like/unlike tek fonksiyon)
  Future<Map<String, dynamic>> toggleLike(
    int blogId,
    bool currentlyLiked,
  ) async {
    try {
      print('🎯 Like toggle: Blog $blogId, Currently liked: $currentlyLiked');

      bool success;
      String action;

      if (currentlyLiked) {
        // Unlike yap
        success = await unlikeBlog(blogId);
        action = 'unliked';
      } else {
        // Like yap
        success = await likeBlog(blogId);
        action = 'liked';
      }

      if (success) {
        // Başarılı olursa güncel blog detayını getir
        try {
          final updatedBlog = await getBlogDetail(blogId);
          return {'success': true, 'action': action, 'blog': updatedBlog};
        } catch (e) {
          // Blog detay alınamazsa sadece success döndür
          return {'success': true, 'action': action};
        }
      } else {
        return {
          'success': false,
          'action': action,
          'error': 'Like işlemi başarısız',
        };
      }
    } catch (e) {
      print('🔴 Toggle like hatası: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
