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

  Future<void> addNote(String title, String content, {int color = 0xFFFFFFFF, String category = 'Umum'}) async {
    final newNote = Note(
      title: title,
      content: content,
      createdAt: DateTime.now(),
      color: color,
      category: category,
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
    final lowerQuery = query.toLowerCase();
    return _notes
        .where((note) => 
            note.title.toLowerCase().contains(lowerQuery) || 
            note.content.toLowerCase().contains(lowerQuery) ||
            note.category.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  // Helper buat dapetin kategori unik (buat dropdown filter nanti)
  List<String> get categories {
    final cats = _notes.map((n) => n.category).toSet().toList();
    cats.sort();
    return cats;
  }
}