enum UserRole { admin, viewer }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;

  UserModel({required this.uid, required this.email, required this.role});

  bool get isAdmin => role == UserRole.admin;
  bool get isViewer => role == UserRole.viewer;
}
