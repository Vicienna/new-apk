import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entities/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'zen_notes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            createdAt TEXT,
            color INTEGER,
            category TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // FIX: Safe migration strategy - hanya add kolom yang hilang, jangan drop data
        if (oldVersion < 2) {
          try {
            // Check apakah table sudah ada
            final tables = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name='notes'"
            );
            
            if (tables.isNotEmpty) {
              // Check kolom apa saja yang ada
              final columns = await db.rawQuery('PRAGMA table_info(notes)');
              final columnNames = <String>{};
              for (var col in columns) {
                columnNames.add(col['name'].toString());
              }
              
              // Add kolom yang hilang (jika ada)
              if (!columnNames.contains('category')) {
                await db.execute(
                  'ALTER TABLE notes ADD COLUMN category TEXT DEFAULT "Umum"'
                );
              }
            }
          } catch (e) {
            // Jika ada error, fallback ke strategy drop & recreate
            print('Migration error, performing full reset: $e');
            await db.execute('DROP TABLE IF EXISTS notes');
            await db.execute('''
              CREATE TABLE notes(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT,
                content TEXT,
                createdAt TEXT,
                color INTEGER,
                category TEXT
              )
            ''');
          }
        }
      },
    );
  }

  Future<int> create(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    if (note.id == null) {
      throw ArgumentError('Note id cannot be null for update');
    }
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
