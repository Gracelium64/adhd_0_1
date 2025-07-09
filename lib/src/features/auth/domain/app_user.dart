class AppUser {
  final String userId;

  AppUser({required this.userId});

  Map<String, dynamic> toJson() {
    return {'userId': userId};
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(userId: json['userId']);
  }

  Map<String, dynamic> toMap() {
    return {'userId': userId};
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(userId: map['userId']);
  }
}
