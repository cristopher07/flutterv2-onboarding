import 'package:flutter/foundation.dart';

@immutable
class UserProfile {
  const UserProfile({
    required this.email,
    required this.rol,
    required this.name,
  });

  final String email;
  final String rol;
  final String name;
}
