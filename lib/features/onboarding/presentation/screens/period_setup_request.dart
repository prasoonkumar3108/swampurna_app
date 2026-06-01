import 'package:intl/intl.dart';

class PeriodSetupRequest {
  final DateTime? lastPeriodStartDate;
  final int periodLengthDays;
  final int cycleLengthDays;
  final bool hasNoIdea;

  // Fallback default constants as per production requirements
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

  Map<String, dynamic> toJson() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    String? startDateStr;
    String? endDateStr;
    List<String> selectedDates = [];

    // Logic: only calculate dates if the user didn't select 'has_no_idea'
    if (!hasNoIdea && lastPeriodStartDate != null) {
      startDateStr = formatter.format(lastPeriodStartDate!);
      
      // formula: [last_period_start_date + period_length_days - 1 day]
      final DateTime endDate = lastPeriodStartDate!.add(Duration(days: periodLengthDays - 1));
      endDateStr = formatter.format(endDate);

      // Generate array of string dates from start to end
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