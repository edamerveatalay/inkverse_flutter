class UserModel {
  final int id;
  final String username;
  final String email;
  final String? avatarUrl; // Opsiyonel: avatar eklemek isterseniz

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? 'Bilinmiyor',
      email: json['email'] ?? 'bilinmiyor@bilinmiyor.com',
      avatarUrl:
          json['avatar_url'] ?? json['avatarUrl'], // İki formatta da destek
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
