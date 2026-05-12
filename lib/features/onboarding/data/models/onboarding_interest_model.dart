import '../../domain/entities/onboarding_interest.dart';

class OnboardingInterestModel extends OnboardingInterest {
  const OnboardingInterestModel({required super.id, required super.name});

  factory OnboardingInterestModel.fromMap(Map<String, dynamic> map) {
    return OnboardingInterestModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
