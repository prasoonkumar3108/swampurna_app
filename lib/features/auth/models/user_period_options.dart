class UserPeriodOptions {
  final String id;
  final String userId;
  final Map<String, String> selections;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPeriodOptions({
    required this.id,
    required this.userId,
    required this.selections,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPeriodOptions.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return UserPeriodOptions(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      selections: (data['selections'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v.toString())),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": {
        "id": id,
        "user_id": userId,
        "selections": selections,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      }
    };
  }
}
