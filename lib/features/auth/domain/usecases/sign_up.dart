import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp({required this.repository});

  final AuthRepository repository;

  Future<void> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}
