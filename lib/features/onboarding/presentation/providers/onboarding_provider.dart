import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/onboarding_interest_model.dart';
import '../../domain/entities/onboarding_interest.dart';
import '../../domain/usecases/toggle_onboarding_interest.dart';

const _defaultSelectedInterestIds = {
  'user-interface',
  'user-research',
  'strategy',
  'design-systems',
};

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
      (ref) => OnboardingController(
        toggleOnboardingInterest: ref.watch(toggleOnboardingInterestProvider),
      ),
    );

final onboardingInterestsProvider = Provider<List<OnboardingInterest>>((ref) {
  return const [
    OnboardingInterestModel(id: 'user-interface', name: 'User Interface'),
    OnboardingInterestModel(id: 'user-experience', name: 'User Experience'),
    OnboardingInterestModel(id: 'user-research', name: 'User Research'),
    OnboardingInterestModel(id: 'ux-writing', name: 'UX Writing'),
    OnboardingInterestModel(id: 'user-testing', name: 'User Testing'),
    OnboardingInterestModel(id: 'service-design', name: 'Service Design'),
    OnboardingInterestModel(id: 'strategy', name: 'Strategy'),
    OnboardingInterestModel(id: 'design-systems', name: 'Design Systems'),
  ];
});

final toggleOnboardingInterestProvider = Provider<ToggleOnboardingInterest>(
  (ref) => const ToggleOnboardingInterest(),
);

@immutable
class OnboardingState {
  const OnboardingState({
    this.pageIndex = 0,
    this.selectedInterestIds = _defaultSelectedInterestIds,
  });

  final int pageIndex;
  final Set<String> selectedInterestIds;

  OnboardingState copyWith({int? pageIndex, Set<String>? selectedInterestIds}) {
    return OnboardingState(
      pageIndex: pageIndex ?? this.pageIndex,
      selectedInterestIds: selectedInterestIds ?? this.selectedInterestIds,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController({
    ToggleOnboardingInterest toggleOnboardingInterest =
        const ToggleOnboardingInterest(),
  }) : _toggleOnboardingInterest = toggleOnboardingInterest,
       super(const OnboardingState());

  final ToggleOnboardingInterest _toggleOnboardingInterest;

  void setPage(int index) {
    state = state.copyWith(pageIndex: index);
  }

  void toggleInterest(String interestId) {
    state = state.copyWith(
      selectedInterestIds: _toggleOnboardingInterest(
        selectedInterestIds: state.selectedInterestIds,
        interestId: interestId,
      ),
    );
  }
}
