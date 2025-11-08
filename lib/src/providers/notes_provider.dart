import 'package:flutter/material.dart';
import 'package:flutter_notes_app/src/models/note_model.dart';
import 'package:flutter_notes_app/src/services/firestore_service.dart';

/// Provider class for managing notes state.
/// This class extends ChangeNotifier to provide reactive state management using Provider.
/// It handles CRUD operations on notes and maintains the list of user notes.
class NotesProvider extends ChangeNotifier {
  /// Instance of FirestoreService for database operations.
  final FirestoreService _firestoreService = FirestoreService();

  /// List of notes for the current user.
  List<NoteModel> _notes = [];

  /// Flag indicating if notes are being loaded.
  bool _isLoading = false;

  /// Error message from the last failed operation.
  String? _errorMessage;

  /// Getters for accessing state from the UI.
  List<NoteModel> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Clear any error messages.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load notes for a specific user from Firestore.
  /// This fetches notes once and updates the local list.
  /// 
  /// Parameters:
  /// - [userId]: The UID of the user whose notes to load.
  Future<void> loadNotes({required String userId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notes = await _firestoreService.getUserNotes(userId: userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load notes. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a stream of notes for real-time updates.
  /// This method returns a stream that emits note list updates whenever data changes in Firestore.
  /// 
  /// Parameters:
  /// - [userId]: The UID of the user whose notes to stream.
  /// 
  /// Returns: A Stream of lists of NoteModel objects.
  Stream<List<NoteModel>> getNotesStream({required String userId}) {
    return _firestoreService.getUserNotesStream(userId: userId);
  }

  /// Add a new note to Firestore.
  /// 
  /// Parameters:
  /// - [content]: The text content of the note.
  /// - [userId]: The UID of the user creating the note.
  /// 
  /// Returns: true if the note was added successfully, false otherwise.
  Future<bool> addNote({
    required String content,
    required String userId,
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      _errorMessage = 'Note content cannot be empty.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final noteId = await _firestoreService.addNote(
        content: content,
        userId: userId,
      );

      // Create a local NoteModel and add it to the list
      final newNote = NoteModel(
        id: noteId,
        content: content,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _notes.insert(0, newNote); // Add to the beginning of the list
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add note. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing note.
  /// 
  /// Parameters:
  /// - [noteId]: The ID of the note to update.
  /// - [content]: The new content for the note.
  /// 
  /// Returns: true if the note was updated successfully, false otherwise.
  Future<bool> updateNote({
    required String noteId,
    required String content,
  }) async {
    // Validate content
    if (content.trim().isEmpty) {
      _errorMessage = 'Note content cannot be empty.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateNote(
        noteId: noteId,
        content: content,
      );

      // Update the local note
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex != -1) {
        _notes[noteIndex] = _notes[noteIndex].copyWith(
          content: content,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update note. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a note from Firestore.
  /// 
  /// Parameters:
  /// - [noteId]: The ID of the note to delete.
  /// 
  /// Returns: true if the note was deleted successfully, false otherwise.
  Future<bool> deleteNote({required String noteId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.deleteNote(noteId: noteId);

      // Remove the note from the local list
      _notes.removeWhere((note) => note.id == noteId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete note. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear all notes from the local list.
  /// This is typically called when a user logs out.
  void clearNotes() {
    _notes = [];
    _errorMessage = null;
    notifyListeners();
  }
}
