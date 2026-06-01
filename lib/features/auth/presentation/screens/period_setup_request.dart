import 'package:intl/intl.dart';

class PeriodSetupRequest {
  final DateTime? lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final bool hasNoIdea;

  // Hardcoded defaults as per production requirements
  final int prePeriodDays = 2;
  final int postPeriodDays = 2;
  final int ovulationStartDay = 11;
  final int ovulationWindowDays = 5;
  final String notes = "Initial setup";

  PeriodSetupRequest({
    this.lastPeriodStartDate,
    required this.periodLengthDays,
    required this.cycleLengthDays,
    required this.hasNoIdea,
  });

  PeriodSetupRequest copyWith({
    DateTime? lastPeriodStartDate,
    int? periodLengthDays,
    int? cycleLengthDays,
    bool? hasNoIdea,
  }) {
    return PeriodSetupRequest(
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
      periodLengthDays: periodLengthDays ?? this.periodLengthDays,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      hasNoIdea: hasNoIdea ?? this.hasNoIdea,
    );
  }

  factory PeriodSetupRequest.fromJson(Map<String, dynamic> json) {
    return PeriodSetupRequest(
      lastPeriodStartDate: json['last_period_start_date'] != null 
          ? DateTime.tryParse(json['last_period_start_date']) 
          : null,
      periodLengthDays: json['period_length_days'] as int? ?? 8,
      cycleLengthDays: json['cycle_length_days'] as int? ?? 28,
      hasNoIdea: json['has_no_idea'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    String? startDateStr;
    String? endDateStr;
    List<String> selectedDates = [];

    if (!hasNoIdea && lastPeriodStartDate != null) {
      startDateStr = formatter.format(lastPeriodStartDate!);
      
      final DateTime endDate = lastPeriodStartDate!.add(Duration(days: periodLengthDays - 1));
      endDateStr = formatter.format(endDate);

      for (int i = 0; i < periodLengthDays; i++) {
        selectedDates.add(formatter.format(lastPeriodStartDate!.add(Duration(days: i))));
      }
    }

    return {
      "last_period_start_date": startDateStr,
      "period_end_date": endDateStr,
      "selected_dates": selectedDates,
      "has_no_idea": hasNoIdea,
      "period_length_days": periodLengthDays,
      "cycle_length_days": cycleLengthDays,
      "pre_period_days": prePeriodDays,
      "post_period_days": postPeriodDays,
      "ovulation_start_day": ovulationStartDay,
      "ovulation_window_days": ovulationWindowDays,
      "notes": notes,
    };
  }
}