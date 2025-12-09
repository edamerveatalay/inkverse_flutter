class Profile {
  final int id;
  final int userId;
  final String? bio;
  final String? profilePhoto;

  Profile({
    required this.id,
    required this.userId,
    this.bio,
    this.profilePhoto,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    //backend’den gelen JSON verisini alıp Flutter’daki Profile modeline dönüştürür.
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      bio: json['bio'],
      profilePhoto: json['profile_photo'],
    );
  }
}
