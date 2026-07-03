// API Response Models matching Swift implementation
class CategoryResponse {
  final List<CategoryData> data;

  CategoryResponse({required this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => CategoryData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryData {
  final String id;
  final String name;

  CategoryData({required this.id, required this.name});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class ArticleResponse {
  final List<Article> data;

  ArticleResponse({required this.data});

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    return ArticleResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Article {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? categoryId;
  final String? slug;

  Article({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.slug,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['image_url']?.toString(), // Map image_url -> imageUrl
      categoryId: json['category_id']
          ?.toString(), 
      slug: json['slug']
          ?.toString(), 
    );
  }
}

// Legacy models for backward compatibility
class CommunityCategory {
  final String id;
  final String name;
  final List<Article> articles;

  CommunityCategory({
    required this.id,
    required this.name,
    required this.articles,
  });

  factory CommunityCategory.fromCategoryData(
    CategoryData categoryData,
    List<Article> articles,
  ) {
    return CommunityCategory(
      id: categoryData.id,
      name: categoryData.name,
      articles: articles,
    );
  }
}

class CommunityArticle {
  final String id;
  final String title;
  final String? imageUrl;
  final String? description;
  final String? categoryId;
  final String? slug;

  CommunityArticle({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
    this.categoryId,
    this.slug,
  });

  factory CommunityArticle.fromArticle(Article article) {
    return CommunityArticle(
      id: article.id,
      title: article.title,
      imageUrl: article.imageUrl,
      description: article.description,
      categoryId: article.categoryId,
      slug:article.slug,
    );
  }
}
