/// Model to hold data collected during onboarding flow
class OnboardingData {
  String email;
  String otp;
  String? source;
  int? birthYear;
  bool? isPregnant;
  DateTime? lastPeriodDate;
  int? periodDuration;
  int? cycleLength;

  OnboardingData({
    required this.email,
    required this.otp,
    this.source,
    this.birthYear,
    this.isPregnant,
    this.lastPeriodDate,
    this.periodDuration,
    this.cycleLength,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'source': source,
      'birthYear': birthYear,
      'isPregnant': isPregnant,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'periodDuration': periodDuration,
      'cycleLength': cycleLength,
    };
  }

  /// Create a copy with updated data
  OnboardingData copyWith({
    String? email,
    String? otp,
    String? source,
    int? birthYear,
    bool? isPregnant,
    DateTime? lastPeriodDate,
    int? periodDuration,
    int? cycleLength,
  }) {
    return OnboardingData(
      email: email ?? this.email,
      otp: otp ?? this.otp,
      source: source ?? this.source,
      birthYear: birthYear ?? this.birthYear,
      isPregnant: isPregnant ?? this.isPregnant,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      periodDuration: periodDuration ?? this.periodDuration,
      cycleLength: cycleLength ?? this.cycleLength,
    );
  }

  @override
  String toString() {
    return 'OnboardingData(email: $email, otp: $otp, source: $source, birthYear: $birthYear, isPregnant: $isPregnant, lastPeriodDate: $lastPeriodDate, periodDuration: $periodDuration, cycleLength: $cycleLength)';
  }
}
