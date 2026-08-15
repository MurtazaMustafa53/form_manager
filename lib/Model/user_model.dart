enum UserRole { dev, admin, viewer, finance }

class UserModel {
  final String uid;
  final String email;
  final UserRole role;

  UserModel({required this.uid, required this.email, required this.role});

  bool get isDev => role == UserRole.dev;
  bool get isAdmin => role == UserRole.admin;
  bool get isViewer => role == UserRole.viewer;
  bool get isFinance => role == UserRole.finance;

  // Permission Restrictions
  bool get canEdit => role == UserRole.admin || role == UserRole.dev;
  bool get canSubmit => role == UserRole.admin || role == UserRole.dev;
  bool get isReadOnly => role == UserRole.viewer;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    UserRole parsedRole;
    switch (map['role'] as String?) {
      case 'dev':
        parsedRole = UserRole.dev;
        break;
      case 'admin':
        parsedRole = UserRole.admin;
        break;
      case 'finance':
        parsedRole = UserRole.finance;
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
