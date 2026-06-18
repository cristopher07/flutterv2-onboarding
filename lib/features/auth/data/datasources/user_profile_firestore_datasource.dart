import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class UserProfileFirestoreDatasource {
  const UserProfileFirestoreDatasource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<UserProfileModel?> getUserProfile({
    required String uid,
    required String fallbackEmail,
  }) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) return null;

    return UserProfileModel.fromFirestore(
      userDoc.data(),
      fallbackEmail: fallbackEmail,
    );
  }
}
