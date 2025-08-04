import 'package:note_to_do/models/note_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NoteDatabase {
  static final NoteDatabase _instance = NoteDatabase._init();
  static NoteDatabase get instance => _instance;
  NoteDatabase._init();
  factory NoteDatabase() => _instance;
  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, "note.db");
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
  CREATE TABLE note(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  date TEXT NOT NULL
  )
  ''');
  }

  Future<void> insertNote(NoteModel note) async {
    final db = await database;
    await db.insert(
      'note',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<NoteModel>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('note');
    return maps.map((map) => NoteModel.fromMap(map)).toList();
  }

  Future<void> updateNote(NoteModel note) async {
    final db = await database;
    await db.update(
      'note',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await database;
    await db.delete('note', where: 'id = ?', whereArgs: [id]);
  }
}
