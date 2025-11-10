import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_notes_app/src/models/note_model.dart';
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _notesCollection = 'notes';


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
  Future<void> deleteNote({required String noteId}) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).delete();
    } catch (e) {
      rethrow;
    }
  }
  Stream<List<NoteModel>> getUserNotesStream({required String userId}) {
    return _firestore
        .collection(_notesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
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
      throw error;
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }
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
      if (e.code == 'failed-precondition' ||
          (e.message != null && e.message!.contains('requires an index'))) {
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
