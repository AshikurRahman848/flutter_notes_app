/// Model class representing a note stored in Firestore.
/// This class handles serialization and deserialization of note data.
class NoteModel {
  /// Unique identifier for the note (Firestore document ID).
  final String id;

  /// The content/text of the note.
  final String content;

  /// The user ID (UID) of the note owner.
  final String userId;

  /// Timestamp when the note was created.
  final DateTime createdAt;

  /// Timestamp when the note was last updated.
  final DateTime updatedAt;

  /// Constructor for NoteModel.
  NoteModel({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert NoteModel to a JSON map for Firestore storage.
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a NoteModel from a Firestore document snapshot.
  /// [id] is the document ID, [data] is the document data.
  factory NoteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return NoteModel(
      id: id,
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy of NoteModel with optional field updates.
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
