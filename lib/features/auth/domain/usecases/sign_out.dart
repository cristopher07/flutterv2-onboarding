import '../repositories/auth_repository.dart';

class SignOut {
  const SignOut({required this.repository});

  final AuthRepository repository;

  Future<void> call() {
    return repository.signOut();
  }
}
