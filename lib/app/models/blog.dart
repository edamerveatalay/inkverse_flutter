class Blog {
  final int id;
  final String title;
  final String content;
  final int userId;
  final bool isPublished;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.isPublished,
  });

  // Backend’den gelen JSON’u model’e dönüştürmek için
  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      isPublished: json['is_published'] ?? false,
    );
  }
}
