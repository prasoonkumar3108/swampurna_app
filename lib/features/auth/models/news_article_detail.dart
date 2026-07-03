class NewsArticleDetail {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String slug;
  final String? subtitle;
  final String? category;

  NewsArticleDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.slug,
    this.subtitle,
    this.category,
  });

  factory NewsArticleDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return NewsArticleDetail(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
      slug: data['slug'] ?? '',
      subtitle: data['subtitle'],
      category: data['category'],
    );
  }
}
