class CycleSnapDetail {
  final String id;
  final String title;
  final String description;
  final String mediaUrl;
  final String mediaType;
  final String status;
  final String createdAt;
  final String? authorEmail;
  final String? authorPicUrl;

  CycleSnapDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.mediaType,
    required this.status,
    required this.createdAt,
    this.authorEmail,
    this.authorPicUrl,
  });

  factory CycleSnapDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return CycleSnapDetail(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mediaUrl: data['media_url'] ?? '',
      mediaType: data['media_type'] ?? 'image',
      status: data['status'] ?? '',
      createdAt: data['created_at'] ?? '',
      authorEmail: data['author']?['email'] ?? '',
      authorPicUrl: data['author']?['picUrl'] ?? ''
      
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "data": {
        "id": id,
        "title": title,
        "description": description,
        "media_url": mediaUrl,
        "media_type": mediaType,
        "status": status,
        "created_at": createdAt,
        "author": {"email": authorEmail,"picUrl": authorPicUrl}
      }
    };
  }
}
