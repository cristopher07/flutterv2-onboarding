import '../repositories/auth_repository.dart';

class SignIn {
  const SignIn({required this.repository});

  final AuthRepository repository;

  Future<void> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
