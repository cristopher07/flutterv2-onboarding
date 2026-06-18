import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.email,
    required this.rol,
    required this.name,
  });

  final String email;
  final String rol;
  final String name;

  factory UserProfileModel.fromFirestore(
    Map<String, dynamic>? data, {
    required String fallbackEmail,
  }) {
    return UserProfileModel(
      email: data?['email'] as String? ?? fallbackEmail,
      rol: data?['rol'] as String? ?? '',
      name: data?['name'] as String? ?? '',
    );
  }

  UserProfile fromModel() {
    return UserProfile(email: email, rol: rol, name: name);
  }
}
