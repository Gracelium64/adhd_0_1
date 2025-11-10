class AppUser {
  final String userId;
  final String userName;
  final String email; // kept locally only; not stored in Firestore
  final String password; // kept locally only; not stored in Firestore
  final bool isPowerUser;
  final bool morningNotificationSilent;

  AppUser({
    required this.userId,
    required this.userName,
    required this.email,
    required this.password,
    required this.isPowerUser,
    required this.morningNotificationSilent,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'password': password,
      'isPowerUser': isPowerUser,
      'morningNotificationSilent': morningNotificationSilent,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
      password: json['password'],
      isPowerUser: json['isPowerUser'] ?? false,
      morningNotificationSilent: json['morningNotificationSilent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      // email/password intentionally excluded from Firestore persistence
      'isPowerUser': isPowerUser,
      'morningNotificationSilent': morningNotificationSilent,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'],
      userName: map['userName'],
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      isPowerUser: map['isPowerUser'] ?? false,
      morningNotificationSilent: map['morningNotificationSilent'] ?? false,
    );
  }
}
