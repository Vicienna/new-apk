import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';
import '../../data/local/database_helper.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  Future<void> fetchNotes() async {
    _notes = await DatabaseHelper.instance.readAllNotes();
    notifyListeners();
  }

  Future<void> addNote(String title, String content) async {
    final newNote = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.create(newNote);
    await fetchNotes();
  }

  Future<void> updateNote(Note note) async {
    await DatabaseHelper.instance.update(note);
    await fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    await DatabaseHelper.instance.delete(id);
    await fetchNotes();
  }

  List<Note> searchNotes(String query) {
    return _notes
        .where((note) => 
            note.title.toLowerCase().contains(query.toLowerCase()) || 
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}