
import 'dart:io' as io;
import 'package:my_notepad/model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper{

  static Database? _db;

  Future<Database?> get db async {

    if(_db != null){
      return _db;
    }

    _db = await initDatabase();
    return _db;


  }

  initDatabase() async{

    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notes.db");
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;

  }

  _onCreate(Database db, int version) async {
    
    await db.execute('CREATE TABLE notes(id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT NOT NULL, createdTime INTEGER)');
    
  }


  Future<int> insert(NotesModel notesModel) async{

    var dbClient = await db;
    return dbClient!.insert("notes", notesModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

  }


  Future<List<NotesModel>> getNotesModelList() async{

    var dbClient = await db;
    final List<Map<String, Object?>>? queryResult = (await dbClient?.query('notes'));
    return queryResult!.map((e) => NotesModel.fromMap(e)).toList();

  }


  Future<void> delete(String id) async{
    var dbClient = await db;

    // Delete the note
    await dbClient!.delete('notes', where: 'id = ?', whereArgs: [id]);

  //   // Reset IDs to keep them sequential
  //   await dbClient.execute('''
  //   CREATE TEMP TABLE temp_notes AS SELECT * FROM notes;
  // ''');
  //   await dbClient.execute('DELETE FROM notes');
  //   await dbClient.execute('''
  //   INSERT INTO notes (id, title, description, createdTime)
  //   SELECT row_number() OVER () AS id, title, description, createdTime FROM temp_notes;
  // ''');
  //   await dbClient.execute('DROP TABLE temp_notes');

  }


  Future<int> edit(NotesModel notesModel) async{
    var dbClient = await db;

    return await dbClient!.update("notes", notesModel.toMap(), where: 'id =?', whereArgs: [notesModel.id]);


  }

  Future<void> deleteAllNotes() async {
    var dbClient = await db;
    await dbClient!.delete('notes'); // Deletes all rows from the 'notes' table
  }


}