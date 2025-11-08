import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_notes_app/src/models/note_model.dart';

/// Service class for handling Firestore database operations.
/// This service provides methods for CRUD operations on notes.
class FirestoreService {
  /// Instance of FirebaseFirestore for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection name for storing notes in Firestore.
  static const String _notesCollection = 'notes';

  /// Add a new note to Firestore.
  /// 
  /// Parameters:
  /// - [content]: The text content of the note.
  /// - [userId]: The UID of the user creating the note.
  /// 
  /// Returns: The ID of the newly created document.
  Future<String> addNote({
    required String content,
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection(_notesCollection).add({
        'content': content,
        'userId': userId,
        'createdAt': now,
        'updatedAt': now,
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing note in Firestore.
  /// 
  /// Parameters:
  /// - [noteId]: The ID of the note to update.
  /// - [content]: The new content for the note.
  /// 
  /// Returns: A Future that completes when the update is done.
  Future<void> updateNote({
    required String noteId,
    required String content,
  }) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).update({
        'content': content,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a note from Firestore.
  /// 
  /// Parameters:
  /// - [noteId]: The ID of the note to delete.
  /// 
  /// Returns: A Future that completes when the deletion is done.
  Future<void> deleteNote({required String noteId}) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all notes for a specific user as a stream.
  /// This provides real-time updates whenever notes change.
  /// 
  /// Parameters:
  /// - [userId]: The UID of the user whose notes to fetch.
  /// 
  /// Returns: A Stream of lists of NoteModel objects.
  Stream<List<NoteModel>> getUserNotesStream({required String userId}) {
    return _firestore
        .collection(_notesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        // Improve the error surfaced by the stream when Firestore requires a composite index.
        .handleError((error) {
      if (error is FirebaseException &&
          (error.code == 'failed-precondition' ||
              (error.message != null && error.message!.contains('requires an index')))) {
        final link = error.message != null && error.message!.contains('https://')
            ? RegExp(r'https?://\S+').firstMatch(error.message!)?.group(0)
            : null;

        throw FirebaseException(
            plugin: error.plugin,
            code: error.code,
            message:
                'Firestore query requires a composite index for this query. ${link ?? "Create a composite index in the Firebase Console: Firestore → Indexes → Add Index."} Original error: ${error.message}');
      }
      // rethrow other errors unchanged so upstream listeners see them
      throw error;
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Fetch all notes for a specific user (one-time fetch).
  /// 
  /// Parameters:
  /// - [userId]: The UID of the user whose notes to fetch.
  /// 
  /// Returns: A Future that resolves to a list of NoteModel objects.
  Future<List<NoteModel>> getUserNotes({required String userId}) async {
    try {
      final snapshot = await _firestore
          .collection(_notesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      // Firestore can return FAILED_PRECONDITION when a composite index is required.
      // Those error messages often include a console link to create the index.
      if (e.code == 'failed-precondition' ||
          (e.message != null && e.message!.contains('requires an index'))) {
        // If Firestore included a console link in the message, keep it; otherwise, give actionable guidance.
        final link = e.message != null && e.message!.contains('https://')
            ? RegExp(r'https?://\S+').firstMatch(e.message!)?.group(0)
            : null;

        throw FirebaseException(
            plugin: e.plugin,
            code: e.code,
            message:
                'Firestore query requires a composite index for this query. ${link ?? "Create a composite index in the Firebase Console: Firestore → Indexes → Add Index."} Original error: ${e.message}');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single note by its ID.
  /// 
  /// Parameters:
  /// - [noteId]: The ID of the note to fetch.
  /// 
  /// Returns: A Future that resolves to a NoteModel object, or null if not found.
  Future<NoteModel?> getNote({required String noteId}) async {
    try {
      final doc = await _firestore.collection(_notesCollection).doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromFirestore(doc.id, doc.data() ?? {});
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
