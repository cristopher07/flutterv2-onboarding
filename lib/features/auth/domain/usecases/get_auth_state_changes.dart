import '../repositories/auth_repository.dart';

class GetAuthStateChanges {
  const GetAuthStateChanges({required this.repository});

  final AuthRepository repository;

  Stream<bool> call() {
    return repository.authStateChanges();
  }
}
