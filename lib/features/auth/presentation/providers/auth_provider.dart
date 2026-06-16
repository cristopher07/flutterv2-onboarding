import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);
  final user = auth.currentUser;

  if (user == null) return null;

  final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final data = userDoc.data();

  final profile = UserProfile(
    email: data?['email'] as String? ?? user.email ?? '',
    rol: data?['rol'] as String? ?? '',
    name: data?['name'] as String? ?? '',
  );

  debugPrint('Rol del usuario: ${profile.rol}');
  debugPrint('Nombre del usuario: ${profile.name}');

  return profile;
});

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
