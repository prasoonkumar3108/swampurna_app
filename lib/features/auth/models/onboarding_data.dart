/// Consolidated model to hold data collected during onboarding flow
class OnboardingData {
  final String email;
  final String otp;
  final String? onboardingSource; // maps to 'source' in some flows
  final String? source; // merged from presentation model
  final int? birthYear;
  final String? pregnancyStatus;
  final bool? isPregnant;
  final String? usingFor;
  final DateTime? lastPeriodDate;
  final int? periodDuration;
  final int? cycleLength;
  final bool hasNoIdea;

  OnboardingData({
    required this.email,
    required this.otp,
    this.source,
    this.onboardingSource,
    this.birthYear,
    this.pregnancyStatus,
    this.isPregnant,
    this.usingFor,
    this.lastPeriodDate,
    this.periodDuration,
    this.cycleLength,
    this.hasNoIdea = false,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'source': source,
      'onboarding_source': onboardingSource,
      'birth_year': birthYear,
      'pregnancy_status': pregnancyStatus,
      'is_pregnant': isPregnant,
      'using_for': usingFor,
      'last_period_date': lastPeriodDate?.toIso8601String(),
      'period_duration': periodDuration,
      'cycle_length': cycleLength,
      'has_no_idea': hasNoIdea,
    };
  }

  /// Create from Map
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      email: json['email'] as String? ?? '',
      otp: json['otp'] as String? ?? '',
      source: json['source'] as String?,
      onboardingSource: json['onboarding_source'] as String?,
      birthYear: json['birth_year'] as int?,
      pregnancyStatus: json['pregnancy_status'] as String?,
      isPregnant: json['is_pregnant'] as bool?,
      usingFor: json['using_for'] as String?,
      lastPeriodDate: json['last_period_date'] != null 
          ? DateTime.tryParse(json['last_period_date'] as String) 
          : null,
      periodDuration: json['period_duration'] as int?,
      cycleLength: json['cycle_length'] as int?,
      hasNoIdea: json['has_no_idea'] as bool? ?? false,
    );
  }

  /// Check if survey fields are complete
  bool get isComplete {
    return onboardingSource != null &&
        birthYear != null &&
        usingFor != null;
  }

  /// Create a copy with updated fields
  OnboardingData copyWith({
    String? email,
    String? otp,
    String? source,
    String? onboardingSource,
    int? birthYear,
    String? pregnancyStatus,
    bool? isPregnant,
    String? usingFor,
    DateTime? lastPeriodDate,
    int? periodDuration,
    int? cycleLength,
    bool? hasNoIdea,
  }) {
    return OnboardingData(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      source: source ?? this.source,
      onboardingSource: onboardingSource ?? this.onboardingSource,
      birthYear: birthYear ?? this.birthYear,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      isPregnant: isPregnant ?? this.isPregnant,
      usingFor: usingFor ?? this.usingFor,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      periodDuration: periodDuration ?? this.periodDuration,
      cycleLength: cycleLength ?? this.cycleLength,
      hasNoIdea: hasNoIdea ?? this.hasNoIdea,
    );
  }

  @override
  String toString() {
    return 'OnboardingData(email: $email, birthYear: $birthYear, usingFor: $usingFor)';
  }
}
