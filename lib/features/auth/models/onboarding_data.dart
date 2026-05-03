class OnboardingData {
  final String? onboardingSource;
  final int? birthYear;
  final String? pregnancyStatus;
  final String? usingFor;

  OnboardingData({
    this.onboardingSource,
    this.birthYear,
    this.pregnancyStatus,
    this.usingFor,
  });

  // Convert to Map for API
  Map<String, dynamic> toApiMap() {
    return {
      'onboarding_source': onboardingSource,
      'birth_year': birthYear,
      'pregnancy_status': pregnancyStatus,
      'using_for': usingFor,
    };
  }

  // Create from Map
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      onboardingSource: json['onboardingSource'] as String?,
      birthYear: json['birthYear'] as int?,
      pregnancyStatus: json['pregnancyStatus'] as String?,
      usingFor: json['usingFor'] as String?,
    );
  }

  // Convert to Map
  Map<String, dynamic> toJson() {
    return {
      'onboarding_source': onboardingSource,
      'birth_year': birthYear,
      'pregnancy_status': pregnancyStatus,
      'using_for': usingFor,
    };
  }

  // Check if all required fields are filled
  bool get isComplete {
    return onboardingSource != null &&
        birthYear != null &&
        pregnancyStatus != null &&
        usingFor != null;
  }

  // Copy with updated field
  OnboardingData copyWith({
    String? onboardingSource,
    int? birthYear,
    String? pregnancyStatus,
    String? usingFor,
  }) {
    return OnboardingData(
      onboardingSource: onboardingSource ?? this.onboardingSource,
      birthYear: birthYear ?? this.birthYear,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      usingFor: usingFor ?? this.usingFor,
    );
  }

  @override
  String toString() {
    return 'OnboardingData(onboardingSource: $onboardingSource, birthYear: $birthYear, pregnancyStatus: $pregnancyStatus, usingFor: $usingFor)';
  }
}
