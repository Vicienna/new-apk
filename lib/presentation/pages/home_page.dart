import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import 'add_note_page.dart';
import '../../domain/entities/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data pas app pertama kali buka
    Future.microtask(() => 
      Provider.of<NoteProvider>(context, listen: false).fetchNotes()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenNotes'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NoteSearchDelegate()),
              );
            },
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, provider, child) {
          if (provider.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.edit_note, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada catatan, Bro!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: provider.notes.length,
            itemBuilder: (context, index) {
              final note = provider.notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    note.content, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await provider.deleteNote(note.id!);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddNotePage(
                          noteId: note.id,
                          initialTitle: note.title,
                          initialContent: note.content,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNotePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteSearchDelegate extends SearchDelegate {
  @override
  List<PopupMenuEntry> buildActions(BuildContext context) {
    return [
      PopupMenuEntry(
        label: 'Hapus Semua',
        value: 'clear',
      )
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final query = query.toLowerCase();
    final results = provider.searchNotes(query);

    if (results.isEmpty) {
      return const Center(child: Text('Gak ada catatan yang cocok, Bro!'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final note = results[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          onTap: () {
            Navigator.pop(context); // Tutup search
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotePage(
                  noteId: note.id,
                  initialTitle: note.title,
                  initialContent: note.content,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context);
    final suggestions = provider.notes;

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final note = suggestions[index];
        return ListTile(
          title: Text(note.title),
          onTap: () {
            query = note.title;
            close();
          },
        );
      },
    );
  }
}