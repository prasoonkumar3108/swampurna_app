
class TrackerArticle {
  final String id;
  final String categoryKey;
  final String categoryLabel;
  final String title;
  final String detailTitle;
  final String content;
  final String cyclePhase;
  final String priority;
  final String slug;
  final String imageUrl;

  TrackerArticle({
    required this.id,
    required this.categoryKey,
    required this.categoryLabel,
    required this.title,
    required this.detailTitle,
    required this.content,
    required this.cyclePhase,
    required this.priority,
    required this.slug,
    required this.imageUrl
  });

  factory TrackerArticle.fromJson(Map<String, dynamic> json) {
    return TrackerArticle(
      id: json['id'] ?? '',
      categoryKey: json['category_key'] ?? '',
      categoryLabel: json['category_label'] ?? '',
      title: json['title'] ?? '',
      detailTitle: json['detail_title'] ?? '',
      content: json['content'] ?? '',
      cyclePhase: json['cycle_phase'] ?? '',
      priority: json['priority'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['imageUrl'] ?? ''
    );
  }
}
