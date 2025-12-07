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
    print('📦 Blog.fromJson çağrıldı');

    // likes_count ve is_liked kontrolü
    if (!json.containsKey('likes_count')) {
      print('⚠️ UYARI: API responseunda likes_count yok!');
    }
    if (!json.containsKey('is_liked')) {
      print('⚠️ UYARI: API responseunda is_liked yok!');
    }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'is_published': isPublished,
      'tags': tags,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // ✅ Artık user?.toJson() çalışacak çünkü UserModel'da toJson var
      'user': user?.toJson(),
    };
  }

  Blog copyWith({
    int? id,
    String? title,
    String? content,
    int? userId,
    bool? isPublished,
    List<String>? tags,
    UserModel? user,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      isPublished: isPublished ?? this.isPublished,
      tags: tags ?? List.from(this.tags),
      user: user ?? this.user,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  String toString() {
    return 'Blog(id: $id, title: "$title", likes: $likesCount, isLiked: $isLiked)';
  }
}
