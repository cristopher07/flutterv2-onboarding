import '../entities/user_profile.dart';

abstract class AuthRepository {
  Stream<bool> authStateChanges();

  bool get isSignedIn;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({required String email, required String password});

  Future<void> signOut();

  Future<UserProfile?> getCurrentUserProfile();
}
