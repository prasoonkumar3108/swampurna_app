class TrackerData {
  final String monthTitle;
  final List<CalendarDay> days;

  TrackerData({required this.monthTitle, required this.days});
}

class CalendarDay {
  final int day;
  final String type; // 'period', 'post', 'ovulation', 'pre', 'none'

  CalendarDay({required this.day, required this.type});
}
