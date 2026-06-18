import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/user_profile_firestore_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_auth_state_changes.dart';
import '../../domain/usecases/get_current_user_profile.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (ref) => FirebaseAuthDatasource(auth: ref.watch(firebaseAuthProvider)),
);

final userProfileFirestoreDatasourceProvider =
    Provider<UserProfileFirestoreDatasource>(
      (ref) =>
          UserProfileFirestoreDatasource(firestore: FirebaseFirestore.instance),
    );

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
    userProfileDatasource: ref.watch(userProfileFirestoreDatasourceProvider),
  );
});

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(repository: ref.watch(authRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(repository: ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(repository: ref.watch(authRepositoryProvider));
});

final getAuthStateChangesProvider = Provider<GetAuthStateChanges>((ref) {
  return GetAuthStateChanges(repository: ref.watch(authRepositoryProvider));
});

final authStateProvider = StreamProvider<bool>((ref) {
  return ref.watch(getAuthStateChangesProvider)();
});

final getCurrentUserProfileProvider = Provider<GetCurrentUserProfile>((ref) {
  return GetCurrentUserProfile(repository: ref.watch(authRepositoryProvider));
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(getCurrentUserProfileProvider)();
});
