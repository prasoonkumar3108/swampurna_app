class TrackerArticleDetail {
  final String id;
  final String categoryKey;
  final String categoryLabel;
  final String slug;
  final String title;
  final String detailTitle;
  final String content;
  final String cyclePhase;
  final String priority;
  final String imageUrl;

  TrackerArticleDetail({
    required this.id,
    required this.categoryKey,
    required this.categoryLabel,
    required this.slug,
    required this.title,
    required this.detailTitle,
    required this.content,
    required this.cyclePhase,
    required this.priority,
    required this.imageUrl
  });

  factory TrackerArticleDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return TrackerArticleDetail(
      id: data['id'] ?? '',
      categoryKey: data['category_key'] ?? '',
      categoryLabel: data['category_label'] ?? '',
      slug: data['slug'] ?? '',
      title: data['title'] ?? '',
      detailTitle: data['detail_title'] ?? '',
      content: data['content'] ?? '',
      cyclePhase: data['cycle_phase'] ?? '',
      priority: data['priority'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
