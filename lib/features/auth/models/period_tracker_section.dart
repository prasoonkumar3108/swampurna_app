
class PeriodTrackerOptionItem {
  final String key;
  final String label;
  final String imageUrl;

  PeriodTrackerOptionItem({required this.key, required this.label, required this.imageUrl});

  factory PeriodTrackerOptionItem.fromJson(Map<String, dynamic> json) {
    return PeriodTrackerOptionItem(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? ''
    );
  }
}

class PeriodTrackerSection {
  final String key;
  final String label;
  final String purpose;
  final String predictionEffect;
  final String confidenceImpact;
  final List<PeriodTrackerOptionItem> options;

  PeriodTrackerSection({
    required this.key,
    required this.label,
    required this.purpose,
    required this.predictionEffect,
    required this.confidenceImpact,
    required this.options,
  });

  factory PeriodTrackerSection.fromJson(Map<String, dynamic> json) {
    return PeriodTrackerSection(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      predictionEffect: json['prediction_effect']?.toString() ?? '',
      confidenceImpact: json['confidence_impact']?.toString() ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => PeriodTrackerOptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}