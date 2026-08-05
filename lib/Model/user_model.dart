enum UserRole { dev, admin, viewer }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;

  UserModel({required this.uid, required this.email, required this.role});

  bool get isDev => role == UserRole.dev;
  bool get isAdmin => role == UserRole.admin;
  bool get isViewer => role == UserRole.viewer;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    UserRole parsedRole;
    switch (map['role'] as String?) {
      case 'dev':
        parsedRole = UserRole.dev;
        break;
      case 'admin':
        parsedRole = UserRole.admin;
        break;
      default:
        parsedRole = UserRole.viewer;
    }
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: parsedRole,
    );
  }
}
