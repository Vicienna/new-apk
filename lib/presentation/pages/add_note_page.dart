import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/note_provider.dart';
import '../../domain/entities/note.dart';

class AddNotePage extends StatefulWidget {
  final int? noteId;
  final String? initialTitle;
  final String? initialContent;
  final int? initialColor;
  final String? initialCategory;

  const AddNotePage({
    super.key, 
    this.noteId, 
    this.initialTitle, 
    this.initialContent,
    this.initialColor,
    this.initialCategory,
  });

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  
  late int _selectedColor;
  List<String> _existingCategories = ['Umum', 'Pekerjaan', 'Pribadi', 'Ide'];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor ?? 0xFFFFFFFF;
    
    if (widget.initialTitle != null) _titleController.text = widget.initialTitle!;
    if (widget.initialContent != null) _contentController.text = widget.initialContent!;
    if (widget.initialCategory != null) _categoryController.text = widget.initialCategory!;
    
    Future.microtask(() {
      final provider = Provider.of<NoteProvider>(context, listen: false);
      setState(() {
        _existingCategories = provider.categories;
        final currentCat = widget.initialCategory ?? 'Umum';
        if (!_existingCategories.contains(currentCat)) {
          _existingCategories.add(currentCat);
        }
      });
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna Catatan'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: Color(_selectedColor),
            onColorChanged: (color) {
              setState(() => _selectedColor = color.value);
            },
            availableColors: const [
              Colors.white, Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
              Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal,
              Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber,
              Colors.orange, Colors.deepOrange, Colors.brown, Colors.grey, Colors.blueGrey,
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final category = _categoryController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi judul dan kontennya dulu, Bro!')),
      );
      return;
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);
    final finalCategory = category.isEmpty ? 'Umum' : category;

    try {
      if (widget.noteId == null) {
        await provider.addNote(
          title, 
          content, 
          color: _selectedColor, 
          category: finalCategory,
        );
      } else {
        // FIX: Add null check dan error handling untuk missing note
        final noteIndex = provider.notes.indexWhere((n) => n.id == widget.noteId);
        if (noteIndex == -1) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Catatan tidak ditemukan, Bro!')),
            );
            Navigator.pop(context);
          }
          return;
        }
        
        final oldNote = provider.notes[noteIndex];
        final updatedNote = oldNote.copyWith(
          title: title,
          content: content,
          color: _selectedColor,
          category: finalCategory,
        );
        await provider.updateNote(updatedNote);
      }
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = Color(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Catatan Baru' : 'Edit Catatan'),
        actions: [
          IconButton(onPressed: _saveNote, icon: const Icon(Icons.check)),
        ],
      ),
      body: Container(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: _showColorPicker,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Warna',
                            style: TextStyle(color: textColor.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
                decoration: InputDecoration(
                  hintText: 'Judul Catatan',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.4)),
                ),
              ),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      style: TextStyle(fontSize: 16, color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.label_outline, color: textColor.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.arrow_drop_down, color: textColor),
                    onSelected: (value) {
                      setState(() {
                        _categoryController.text = value;
                      });
                    },
                    itemBuilder: (context) => _existingCategories.map((cat) => PopupMenuItem(
                      value: cat,
                      child: Text(cat),
                    )).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(fontSize: 18, color: textColor, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Tulis curhatan lu di sini...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: textColor.withOpacity(0.4)),
                  ),
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
