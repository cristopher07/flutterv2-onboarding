import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserProfile {
  const GetCurrentUserProfile({required this.repository});

  final AuthRepository repository;

  Future<UserProfile?> call() {
    return repository.getCurrentUserProfile();
  }
}
