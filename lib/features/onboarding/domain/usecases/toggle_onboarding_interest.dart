class ToggleOnboardingInterest {
  const ToggleOnboardingInterest();

  Set<String> call({
    required Set<String> selectedInterestIds,
    required String interestId,
  }) {
    final updated = {...selectedInterestIds};
    if (!updated.add(interestId)) {
      updated.remove(interestId);
    }
    return updated;
  }
}
