class Profile {
  final int? id;
  final int? userId;
  final String? name;
  final String? bio;
  final String? profilePhoto;

  Profile({this.id, this.userId, this.name, this.bio, this.profilePhoto});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      bio: json['bio'],
      profilePhoto: json['profile_image'],
    );
  }
}
