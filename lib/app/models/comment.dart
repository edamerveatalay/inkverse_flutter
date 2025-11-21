// lib/app/models/comment.dart

class Comment {
  final int id;
  final String content;
  final int userId;
  final int blogId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? author;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.blogId,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      userId: json['user_id'],
      blogId: json['blog_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      author: json['author'],
    );
  }
}
