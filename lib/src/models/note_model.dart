class NoteModel {
  final String id;
  final String content;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  NoteModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
  factory NoteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NoteModel(
      id: id,
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
  NoteModel copyWith({
    String? id,
    String? content,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, content: $content, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
