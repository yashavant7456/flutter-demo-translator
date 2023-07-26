import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'Model.dart';

class DatabaseHelper {
  static final _databaseName = "translation";
  static final _databaseVersion = 1;
  static final _tableName = "note";

  static final columnId = "id";
  static final columnName = "name";

  static Database _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path =
        join(documentDirectory.path, _databaseName); //directory.path + _dbName;
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''

      CREATE TABLE $_tableName(
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnName TEXT)


    ''');
  }

//Insert
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List> getAllRecords() async {
    var db = await instance.database;
    return await db.rawQuery("SELECT * FROM $_tableName");
    //return result.toList();
  }

  Future<List> search() async {
    var db = await instance.database;
    var res = await db.query("$_tableName",
//        where: "name LIKE '% $ ? %'",whereArgs: ["title"]
        where: "name LIKE '%?%'",
        whereArgs: ["title"]);
  }

//Update
  Future update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String eId = row[columnId];
    return await db
        .update(_tableName, row, where: '$columnId = ?', whereArgs: [eId]);
  }

  //Update
  Future updates(int e_id) async {
    Database db = await instance.database;
    var res = await db.update(_tableName, {"name": "aa"},
        where: "id = ?", whereArgs: [e_id]);
    return res;
  }

  Future<int> updatee(Employee employee) async {
    var dbClient = await database;
    return await dbClient.update("$_tableName", employee.toMap(),
        where: 'id = ?', whereArgs: [employee.id]);
  }

//Delete
  Future<String> delete(String e_id) async {
    Database db = await instance.database;
    var res =
        await db.delete(_tableName, where: " $columnId = ?", whereArgs: [e_id]);
    return res.toString();
  }

  Future<List<Map<String, dynamic>>> querySpecific(String username) async {
    Database db = await instance.database;
    var result =
        await db.rawQuery('SELECT * FROM $_tableName WHERE name=?', [username]);
    return result;
  }
}
