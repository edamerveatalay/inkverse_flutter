import 'package:inkverse_flutter/app/models/user.dart';

class Blog {
  final int id;
  final String title;
  final String content;
  final int userId;
  final bool isPublished;
  final List<String> tags;
  final UserModel? user;
  int likesCount;
  bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.isPublished,
    required this.tags,
    this.user,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'] ?? 'Başlıksız',
      content: json['content'] ?? '',
      userId: json['user_id'],
      isPublished: json['is_published'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      imageUrl: json['image_url'],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
