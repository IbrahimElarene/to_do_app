import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  Note({required this.id, required this.title, required this.content});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}

class Todo {
  final int? id;
  final String title;
  final int? value;
  Todo({
    required this.id,
    required this.title,
    this.value = 0,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
    };
  }
}

class sqlHelper {
  Database? database;
  Future getDatabase() async {
    if (database != null) return database;
    database = await initDatabase();
    return database;
  }

  Future initDatabase() async {
    String path = join(await getDatabasesPath(), 'gdsc_benha_2024.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      Batch batch = db.batch();
      batch.execute('''
      CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT
      )
      ''');
      batch.execute('''
      
      CREATE TABLE todos(
      id INTEGER PRIMARY KEY,
      title TEXT,
      value INTEGER
      )
      
      ''');
      batch.commit();
    });
  }

  Future insertToDo(Todo todo) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert('todo', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.commit();
  }

  Future insertNote(Note note) async {
    Database db = await getDatabase();
    Batch batch = db.batch();
    batch.insert('note', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    batch.commit();
  }

  Future<List<Map>> loadNotes() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('notes');
    return List.generate(maps.length, (index) {
      return Note(
        id: maps[index]['id'],
        title: maps[index]['title'],
        content: maps[index]['content'],
      ).toMap();
    });
  }

  Future loadTodos() async {
    Database db = await getDatabase();
    List<Map> maps = await db.query('todos');
    return List.generate(maps.length, (index) {
      return Todo(
        id: maps[index]['id'],
        title: maps[index]['title'],
        value: maps[index]['value'],
      ).toMap();
    });
  }

  Future updateNote(Note newNote) async {
    Database db = await getDatabase();
    await db.update('notes', newNote.toMap(),
        where: 'id:?', whereArgs: [newNote.id]);
  }

  Future updateTodoChecked(int id, int currentValue) async {
    Database db = await getDatabase();
    Map<String, dynamic> values = {
      'value': currentValue == 0 ? 1 : 0,
    };
    await db.update(
      'todos',
      values,
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future deleteAllNotes() async {
    Database db = await getDatabase();
    await db.delete('notes');
  }

  Future deleteAllTodos() async {
    Database db = await getDatabase();
    await db.delete('todos');
  }

  Future deleteNotes(int id) async {
    Database db = await getDatabase();
    await db.delete(
      'notes',
      where: 'id=?',
      whereArgs: [id],
    );
  }
}
