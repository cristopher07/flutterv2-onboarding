import 'package:flutter/foundation.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/user_profile_firestore_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.authDatasource,
    required this.userProfileDatasource,
  });

  final FirebaseAuthDatasource authDatasource;
  final UserProfileFirestoreDatasource userProfileDatasource;

  @override
  Stream<bool> authStateChanges() {
    return authDatasource.authStateChanges().map((user) => user != null);
  }

  @override
  bool get isSignedIn => authDatasource.currentUser != null;

  @override
  Future<void> signIn({required String email, required String password}) {
    return authDatasource.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp({required String email, required String password}) {
    return authDatasource.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return authDatasource.signOut();
  }

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = authDatasource.currentUser;

    if (user == null) return null;

    final profileModel = await userProfileDatasource.getUserProfile(
      uid: user.uid,
      fallbackEmail: user.email ?? '',
    );
    final profile = profileModel?.fromModel();

    debugPrint('Rol del usuario: ${profile?.rol}');
    debugPrint('Nombre del usuario: ${profile?.name}');

    return profile;
  }
}
